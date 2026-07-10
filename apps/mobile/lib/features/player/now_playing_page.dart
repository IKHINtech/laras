import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../l10n/app_localizations.dart';
import '../library/local_music_store.dart';
import '../library/song.dart';
import 'lyrics_detail_page.dart';
import 'player_controller.dart';
import 'lyrics_service.dart';

class NowPlayingRoute {
  NowPlayingRoute._();

  static const name = '/now-playing';
  static bool _open = false;

  static Future<void> open(
    BuildContext context, {
    required PlayerController controller,
    required LocalMusicStore store,
  }) async {
    if (_open || controller.currentSong == null) return;
    _open = true;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: name),
          builder: (_) => NowPlayingPage(
            controller: controller,
            store: store,
          ),
        ),
      );
    } finally {
      _open = false;
    }
  }
}

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
    final l10n = AppLocalizations.of(context)!;
    final song = widget.controller.currentSong;
    if (song == null) {
      return Scaffold(body: Center(child: Text(l10n.noSongPlaying)));
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
          statusBarBrightness: Theme.of(context).brightness == Brightness.dark
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
                          _MetaChip(
                              icon: Icons.folder, label: song.folderLabel),
                          _MetaChip(
                            icon: Icons.history,
                            label: history == null
                                ? l10n.firstPlay
                                : l10n.playsCount(history!.playCount),
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
                      AnimatedBuilder(
                        animation: widget.controller,
                        builder: (context, _) {
                          final playing = widget.controller.isPlaying;
                          final trackMode = widget.controller.trackPlayMode;
                          final sleepLabel = widget.controller.sleepTimerLabel;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ControlSideButton(
                                icon: switch (trackMode) {
                                  TrackPlayMode.normal => Icons.repeat,
                                  TrackPlayMode.shuffle => Icons.shuffle,
                                  TrackPlayMode.repeatAll => Icons.repeat,
                                  TrackPlayMode.repeatOne => Icons.repeat_one,
                                },
                                label: switch (trackMode) {
                                  TrackPlayMode.normal => l10n.normalMode,
                                  TrackPlayMode.shuffle => l10n.shuffleMode,
                                  TrackPlayMode.repeatAll => l10n.loopMode,
                                  TrackPlayMode.repeatOne => l10n.loopOneMode,
                                },
                                active: trackMode != TrackPlayMode.normal,
                                onPressed: widget.controller.cycleTrackPlayMode,
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                iconSize: 36,
                                onPressed: widget.controller.hasPrevious
                                    ? widget.controller.previous
                                    : null,
                                icon: const Icon(Icons.skip_previous),
                              ),
                              const SizedBox(width: 12),
                              _GradientPlayPauseButton(
                                playing: playing,
                                onPressed: widget.controller.playOrPause,
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                iconSize: 36,
                                onPressed: widget.controller.hasNext
                                    ? widget.controller.next
                                    : null,
                                icon: const Icon(Icons.skip_next),
                              ),
                              const SizedBox(width: 4),
                              _ControlSideButton(
                                icon: sleepLabel == 'Off'
                                    ? Icons.timer_off_outlined
                                    : Icons.timer_outlined,
                                label: sleepLabel == 'Off'
                                    ? l10n.off
                                    : '${sleepLabel}m',
                                active: sleepLabel != 'Off',
                                onPressed:
                                    widget.controller.cycleSleepTimerPreset,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.queuePosition(
                          widget.controller.currentIndex + 1,
                          widget.controller.queue.length,
                        ),
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
                                  builder: (_) => LyricsDetailPage(
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: theme.colorScheme.primary.withValues(alpha: 0.92),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlSideButton extends StatelessWidget {
  const _ControlSideButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.72);
    return SizedBox(
      width: 56,
      height: 72,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, size: 22, color: color),
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: active
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPlayPauseButton extends StatelessWidget {
  const _GradientPlayPauseButton({
    required this.playing,
    required this.onPressed,
  });

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x408B5CF6),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFFF59E0B),
              ],
            ),
          ),
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 42,
            color: Colors.white,
          ),
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (lyrics.isEmpty) {
      return _LyricsCardShell(
        song: song,
        artworkUri: artworkUri,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.lyricsPreview,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.noLyricsFound,
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
                      l10n.lyricsPreview,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (source != null)
                    Text(
                      l10n.sourceText(source!.label),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                ],
              ),
              SizedBox(height: dense ? 8 : (compact ? 12 : 16)),
              for (final line in visibleLines)
                Padding(
                  padding:
                      EdgeInsets.only(bottom: dense ? 6 : (compact ? 8 : 10)),
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
                        label: Text(l10n.viewLyrics),
                      )
                    : FilledButton.icon(
                        onPressed: onOpenDetail,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
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
                        label:
                            Text(compact ? l10n.viewLyrics : l10n.lyricsDetail),
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
    final palette = LyricsThemePalette.fromTheme(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
        Container(
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
                        child: ArtworkFileImage(uri: artworkUri!),
                      ),
                    ),
                  ),
                ),
              SizedBox.expand(child: child),
            ],
          ),
        ),
      ],
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
