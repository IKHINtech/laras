import 'dart:io';

import '../library/local_music_store.dart';
import '../library/song.dart';

class LyricsService {
  Future<List<LyricLine>> loadLyrics(Song song, LocalMusicStore store) async {
    if (!song.isLocal || song.filePath.isEmpty) return const <LyricLine>[];

    final cached = await store.loadLyricsPath(song.id);
    if (cached != null) {
      final file = File(cached);
      if (await file.exists()) {
        return _parse(await file.readAsString());
      }
    }

    final found = await _findLyricsPath(song);
    if (found == null) return const <LyricLine>[];

    await store.saveLyricsPath(song.id, found);
    return _parse(await File(found).readAsString());
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

  List<LyricLine> _parse(String raw) {
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
          ),
        );
      }
    }

    lines.sort((a, b) => a.at.compareTo(b.at));
    return lines;
  }
}

class LyricLine {
  const LyricLine({required this.at, required this.text});

  final Duration at;
  final String text;
}
