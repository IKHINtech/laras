import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import '../library/local_music_store.dart';
import '../library/song.dart';

enum LyricsSource {
  lrc('.lrc'),
  metadata('metadata');

  const LyricsSource(this.label);

  final String label;
}

class LyricsLoadResult {
  const LyricsLoadResult({
    required this.lines,
    this.source,
  });

  final List<LyricLine> lines;
  final LyricsSource? source;
}

class LyricsService {
  Future<LyricsLoadResult> loadLyrics(
    Song song,
    LocalMusicStore store,
  ) async {
    if (!song.isLocal || song.filePath.isEmpty) {
      return const LyricsLoadResult(lines: <LyricLine>[]);
    }

    final cached = await store.loadLyricsPath(song.id);
    if (cached != null) {
      final file = File(cached);
      if (await file.exists()) {
        return LyricsLoadResult(
          lines: _parseLrc(await file.readAsString()),
          source: LyricsSource.lrc,
        );
      }
    }

    final found = await _findLyricsPath(song);
    if (found != null) {
      await store.saveLyricsPath(song.id, found);
      return LyricsLoadResult(
        lines: _parseLrc(await File(found).readAsString()),
        source: LyricsSource.lrc,
      );
    }

    return _loadMetadataLyrics(song);
  }

  Future<String?> _findLyricsPath(Song song) async {
    final audioFile = File(song.filePath);
    final folder = audioFile.parent;
    if (!await folder.exists()) return null;

    final fileName = audioFile.uri.pathSegments.last;
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;

    final direct = File('${folder.path}/$base.lrc');
    if (await direct.exists()) return direct.path;

    final byTitle = File('${folder.path}/${song.title}.lrc');
    if (await byTitle.exists()) return byTitle.path;

    await for (final entity in folder.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.lrc')) {
        return entity.path;
      }
    }
    return null;
  }

  Future<LyricsLoadResult> _loadMetadataLyrics(Song song) async {
    final file = File(song.filePath);
    if (!await file.exists()) return const LyricsLoadResult(lines: <LyricLine>[]);

    try {
      final metadata = readMetadata(file, getImage: false);
      final lyrics = metadata.lyrics?.trim();
      if (lyrics != null && lyrics.isNotEmpty) {
        return LyricsLoadResult(
          lines: _parseMetadataText(lyrics),
          source: LyricsSource.metadata,
        );
      }
    } catch (_) {
      return const LyricsLoadResult(lines: <LyricLine>[]);
    }

    return const LyricsLoadResult(lines: <LyricLine>[]);
  }

  List<LyricLine> _parseLrc(String raw) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{1,3}))?\]');

    for (final source in raw.split('\n')) {
      final matches = regex.allMatches(source).toList();
      if (matches.isEmpty) continue;
      final text = source.replaceAll(regex, '').trim();

      for (final match in matches) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final fraction = int.parse((match.group(3) ?? '0').padRight(3, '0'));
        lines.add(
          LyricLine(
            at: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: fraction,
            ),
            text: text.isEmpty ? '...' : text,
            isTimed: true,
          ),
        );
      }
    }

    lines.sort((a, b) => a.at.compareTo(b.at));
    return lines;
  }

  List<LyricLine> _parseMetadataText(String raw) {
    final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (text.isEmpty) return const <LyricLine>[];

    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(
          (line) => LyricLine(
            at: Duration.zero,
            text: line,
            isTimed: false,
          ),
        )
        .toList();
  }
}

class LyricLine {
  const LyricLine({
    required this.at,
    required this.text,
    required this.isTimed,
  });

  final Duration at;
  final String text;
  final bool isTimed;
}
