import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../library/local_music_store.dart';
import '../library/song.dart';
import 'player_controller.dart';
import 'lyrics_service.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.controller,
    required this.store,
  });

  final PlayerController controller;
  final LocalMusicStore store;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final lyricsService = LyricsService();
  List<LyricLine> lyrics = const <LyricLine>[];
  LyricsSource? lyricsSource;
  String? loadedSongId;
  PlaybackHistory? history;
  Uri? lyricsArtworkUri;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _loadLyrics();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    final songId = widget.controller.currentSong?.id;
    if (songId != loadedSongId) {
      _loadLyrics();
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadLyrics({bool forceReload = false}) async {
    final song = widget.controller.currentSong;
    loadedSongId = song?.id;
    if (song == null) {
      lyrics = const <LyricLine>[];
      lyricsSource = null;
      history = null;
      lyricsArtworkUri = null;
      if (mounted) setState(() {});
      return;
    }
    if (forceReload) {
      await widget.store.clearLyricsCache(song.id);
    }
    final result = await lyricsService.loadLyrics(
      song,
      widget.store,
      forceReload: forceReload,
    );
    lyrics = result.lines;
    lyricsSource = result.source;
    history = await widget.store.loadPlaybackHistory(song.id);
    lyricsArtworkUri = await widget.controller.resolveArtworkUri(song);
    if (mounted) setState(() {});
  }

  String _format(Duration value) {
    final total = value.inSeconds;
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.controller.currentSong;
    if (song == null) {
      return const Scaffold(body: Center(child: Text('No song playing')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          statusBarBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.dark
                  : Brightness.light,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 36),
                      Expanded(
                        child: Center(
                          child: _ArtworkCard(song: song),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(song.artistLabel,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(song.albumLabel,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _MetaChip(icon: Icons.folder, label: song.folderLabel),
                          _MetaChip(
                            icon: Icons.history,
                            label: history == null
                                ? 'First play'
                                : '${history!.playCount} plays',
                          ),
                          StreamBuilder<Duration>(
                            stream: widget.controller.player.positionStream,
                            builder: (context, snapshot) {
                              final duration = widget.controller.duration;
                              final position =
                                  snapshot.data ?? widget.controller.position;
                              final remaining = duration - position;
                              return _MetaChip(
                                icon: Icons.access_time,
                                label:
                                    '-${_format(remaining.isNegative ? Duration.zero : remaining)}',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProgressSection(
                        controller: widget.controller,
                        format: _format,
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<PlayerState>(
                        stream: widget.controller.player.playerStateStream,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ??
                              widget.controller.isPlaying;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 36,
                                onPressed: widget.controller.hasPrevious
                                    ? widget.controller.previous
                                    : null,
                                icon: const Icon(Icons.skip_previous),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonal(
                                onPressed: widget.controller.playOrPause,
                                style: FilledButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(18),
                                ),
                                child: Icon(
                                  playing ? Icons.pause : Icons.play_arrow,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                iconSize: 36,
                                onPressed: widget.controller.hasNext
                                    ? widget.controller.next
                                    : null,
                                icon: const Icon(Icons.skip_next),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.controller.currentIndex + 1} / ${widget.controller.queue.length} in queue',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<Duration>(
                          stream: widget.controller.player.positionStream,
                          builder: (context, snapshot) {
                            final position =
                                snapshot.data ?? widget.controller.position;
                            final activeIndex = _activeLyricIndex(position);
                            return _LyricsPreviewCard(
                              song: song,
                              artworkUri: lyricsArtworkUri,
                              lyrics: lyrics,
                              source: lyricsSource,
                              activeIndex: activeIndex,
                              onOpenDetail: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _LyricsDetailPage(
                                    controller: widget.controller,
                                    song: song,
                                    artworkUri: lyricsArtworkUri,
                                    lyrics: lyrics,
                                    source: lyricsSource,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _CircleTopButton(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      _CircleTopButton(
                        icon: Icons.refresh,
                        onPressed: () => _loadLyrics(forceReload: true),
                      ),
                      const SizedBox(width: 8),
                      _CircleTopButton(
                        icon: Icons.queue_music,
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (_) =>
                              _QueueSheet(controller: widget.controller),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _activeLyricIndex(Duration position) {
    if (lyrics.isEmpty) return -1;
    if (!lyrics.any((line) => line.isTimed)) return -1;
    var active = 0;
    for (var i = 0; i < lyrics.length; i++) {
      if (lyrics[i].isTimed && lyrics[i].at <= position) {
        active = i;
      } else {
        break;
      }
    }
    return active;
  }
}

class _CircleTopButton extends StatelessWidget {
  const _CircleTopButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: song.artworkId == null
            ? Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.music_note, size: 96),
              )
            : QueryArtworkWidget(
                id: song.artworkId!,
                type: ArtworkType.AUDIO,
                artworkFit: BoxFit.cover,
                nullArtworkWidget: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.music_note, size: 96),
                ),
              ),
      ),
    );
  }
}

class _ProgressSection extends StatefulWidget {
  const _ProgressSection({
    required this.controller,
    required this.format,
  });

  final PlayerController controller;
  final String Function(Duration value) format;

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection> {
  bool dragging = false;
  double dragValueMs = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: widget.controller.player.positionStream,
      builder: (context, snapshot) {
        final duration = widget.controller.duration;
        final position = dragging
            ? Duration(milliseconds: dragValueMs.round())
            : (snapshot.data ?? widget.controller.position);
        final maxMs = duration.inMilliseconds <= 0
            ? 1.0
            : duration.inMilliseconds.toDouble();

        return Column(
          children: [
            Slider(
              value: position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble(),
              max: maxMs,
              onChanged: (value) => setState(() {
                dragging = true;
                dragValueMs = value;
              }),
              onChangeEnd: (value) async {
                setState(() {
                  dragging = false;
                  dragValueMs = value;
                });
                await widget.controller
                    .seek(Duration(milliseconds: value.round()));
              },
            ),
            Row(
              children: [
                Text(widget.format(position)),
                const Spacer(),
                Text(widget.format(duration)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _QueueSheet extends StatelessWidget {
  const _QueueSheet({required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final queue = controller.queue;
    return SafeArea(
      child: ListView.builder(
        itemCount: queue.length,
        itemBuilder: (_, index) {
          final song = queue[index];
          final active = index == controller.currentIndex;
          return ListTile(
            selected: active,
            leading: active
                ? const Icon(Icons.graphic_eq)
                : const Icon(Icons.music_note),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artistLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              await controller.skipTo(index);
              if (context.mounted) Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

class _LyricsPreviewCard extends StatelessWidget {
  const _LyricsPreviewCard({
    required this.song,
    required this.artworkUri,
    required this.lyrics,
    required this.activeIndex,
    required this.source,
    required this.onOpenDetail,
  });

  final Song song;
  final Uri? artworkUri;
  final List<LyricLine> lyrics;
  final int activeIndex;
  final LyricsSource? source;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (lyrics.isEmpty) {
      return _LyricsCardShell(
        song: song,
        artworkUri: artworkUri,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pratinjau lirik',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada lirik yang ditemukan dari .lrc atau metadata.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.86),
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    final previewLines = _previewLines();
    return _LyricsCardShell(
      song: song,
      artworkUri: artworkUri,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 250;
          final dense = constraints.maxHeight < 210;
          final visibleLines = dense
              ? previewLines.take(2)
              : compact
                  ? previewLines.take(3)
                  : previewLines;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pratinjau lirik',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (source != null)
                    Text(
                      'Source: ${source!.label}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                ],
              ),
              SizedBox(height: dense ? 8 : (compact ? 12 : 16)),
              for (final line in visibleLines)
                Padding(
                  padding: EdgeInsets.only(bottom: dense ? 6 : (compact ? 8 : 10)),
                  child: Text(
                    line.text,
                    maxLines: dense ? 1 : (compact ? 2 : 1),
                    overflow: TextOverflow.ellipsis,
                    style: (dense
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(
                      color: line.isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.76),
                      fontWeight:
                          line.isActive ? FontWeight.w800 : FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: dense
                    ? TextButton.icon(
                        onPressed: onOpenDetail,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                        icon: const Icon(Icons.open_in_full_rounded, size: 16),
                        label: const Text('Lihat lirik'),
                      )
                    : FilledButton.icon(
                        onPressed: onOpenDetail,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF53273A),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 14 : 18,
                            vertical: compact ? 8 : 12,
                          ),
                        ),
                        icon: Icon(
                          Icons.open_in_full_rounded,
                          size: compact ? 16 : 18,
                        ),
                        label: Text(compact ? 'Lihat lirik' : 'Detail lirik'),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_PreviewLyricLine> _previewLines() {
    if (lyrics.isEmpty) return const [];
    if (activeIndex < 0) {
      return lyrics
          .take(4)
          .map((line) => _PreviewLyricLine(text: line.text, isActive: false))
          .toList();
    }

    final start = (activeIndex - 2).clamp(0, lyrics.length - 1);
    final end = (start + 4).clamp(0, lyrics.length);
    return [
      for (var i = start; i < end; i++)
        _PreviewLyricLine(
          text: lyrics[i].text,
          isActive: i == activeIndex,
        ),
    ];
  }
}

class _LyricsCardShell extends StatelessWidget {
  const _LyricsCardShell({
    required this.song,
    required this.artworkUri,
    required this.child,
  });

  final Song song;
  final Uri? artworkUri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = _LyricsThemePalette.fromTheme(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.cardGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (artworkUri != null)
            Positioned(
              top: 18,
              right: 22,
              child: Opacity(
                opacity: 0.16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 108,
                    height: 108,
                    child: _ArtworkFileImage(uri: artworkUri!),
                  ),
                ),
              ),
            ),
          Positioned(
            top: -28,
            right: -20,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.glowStrong,
              ),
            ),
          ),
          Positioned(
            bottom: -42,
            left: -24,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.glowSoft,
              ),
            ),
          ),
          SizedBox.expand(child: child),
        ],
      ),
    );
  }
}

class _LyricsDetailPage extends StatelessWidget {
  const _LyricsDetailPage({
    required this.controller,
    required this.song,
    required this.artworkUri,
    required this.lyrics,
    required this.source,
  });

  final PlayerController controller;
  final Song song;
  final Uri? artworkUri;
  final List<LyricLine> lyrics;
  final LyricsSource? source;

  @override
  Widget build(BuildContext context) {
    final palette = _LyricsThemePalette.fromTheme(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.detailGradient,
              ),
            ),
          ),
          if (artworkUri != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.16,
                child: _ArtworkFileImage(uri: artworkUri!),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.detailOverlay,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: StreamBuilder<Duration>(
                stream: controller.player.positionStream,
                builder: (context, snapshot) {
                  final activeIndex =
                      _resolveActiveIndex(snapshot.data ?? controller.position);
                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              color: Colors.white,
                              iconSize: 34,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artistLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(width: 48, height: 48),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (source != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Text(
                              'Source: ${source!.label}',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _LyricsTimelineList(
                          lyrics: lyrics,
                          activeIndex: activeIndex,
                          foregroundColor: Colors.white,
                          fadedColor: Colors.white.withValues(alpha: 0.48),
                          centerActive: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _resolveActiveIndex(Duration position) {
    if (lyrics.isEmpty) return -1;
    if (!lyrics.any((line) => line.isTimed)) return -1;
    var active = 0;
    for (var i = 0; i < lyrics.length; i++) {
      if (lyrics[i].isTimed && lyrics[i].at <= position) {
        active = i;
      } else {
        break;
      }
    }
    return active;
  }
}

class _LyricsThemePalette {
  const _LyricsThemePalette({
    required this.cardGradient,
    required this.detailGradient,
    required this.detailOverlay,
    required this.glowStrong,
    required this.glowSoft,
  });

  final List<Color> cardGradient;
  final List<Color> detailGradient;
  final List<Color> detailOverlay;
  final Color glowStrong;
  final Color glowSoft;

  factory _LyricsThemePalette.fromTheme(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final top = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.26),
      scheme.primaryContainer,
    );
    final mid = Color.alphaBlend(
      scheme.secondary.withValues(alpha: 0.18),
      scheme.surfaceContainerHigh,
    );
    final bottom = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.42),
      scheme.surface,
    );
    final detailTop = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.3),
      scheme.primaryContainer,
    );
    final detailMid = Color.alphaBlend(
      scheme.secondary.withValues(alpha: 0.22),
      scheme.surfaceContainer,
    );
    final detailBottom = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.58),
      scheme.surface,
    );
    return _LyricsThemePalette(
      cardGradient: [top, mid, bottom],
      detailGradient: [detailTop, detailMid, detailBottom],
      detailOverlay: [
        scheme.primary.withValues(alpha: 0.14),
        Colors.black.withValues(alpha: 0.42),
        Colors.black.withValues(alpha: 0.68),
      ],
      glowStrong: scheme.onSurface.withValues(alpha: 0.06),
      glowSoft: scheme.onSurface.withValues(alpha: 0.035),
    );
  }
}

class _ArtworkFileImage extends StatelessWidget {
  const _ArtworkFileImage({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: FileImage(File(uri.toFilePath())),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _LyricsTimelineList extends StatefulWidget {
  const _LyricsTimelineList({
    required this.lyrics,
    required this.activeIndex,
    required this.foregroundColor,
    required this.fadedColor,
    required this.centerActive,
  });

  final List<LyricLine> lyrics;
  final int activeIndex;
  final Color foregroundColor;
  final Color fadedColor;
  final bool centerActive;

  @override
  State<_LyricsTimelineList> createState() => _LyricsTimelineListState();
}

class _LyricsTimelineListState extends State<_LyricsTimelineList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = <int, GlobalKey>{};
  int _lastScrolledIndex = -1;

  @override
  void didUpdateWidget(covariant _LyricsTimelineList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex >= 0 && widget.activeIndex != _lastScrolledIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive() {
    if (!mounted) return;
    final key = _lineKeys[widget.activeIndex];
    final context = key?.currentContext;
    if (context == null) return;
    _lastScrolledIndex = widget.activeIndex;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: widget.centerActive ? 0.4 : 0.38,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      itemCount: widget.lyrics.length,
      itemBuilder: (_, index) {
        final active = index == widget.activeIndex;
        final key = _lineKeys.putIfAbsent(index, GlobalKey.new);
        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            widget.lyrics[index].text,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: active ? widget.foregroundColor : widget.fadedColor,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                  height: 1.18,
                ),
          ),
        );
      },
    );
  }
}

class _PreviewLyricLine {
  const _PreviewLyricLine({
    required this.text,
    required this.isActive,
  });

  final String text;
  final bool isActive;
}
