import 'dart:io';

import 'package:flutter/material.dart';

import '../library/song.dart';
import 'lyrics_service.dart';
import 'player_controller.dart';

class LyricsDetailPage extends StatelessWidget {
  const LyricsDetailPage({
    super.key,
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
    final palette = LyricsThemePalette.fromTheme(context);
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
                child: ArtworkFileImage(uri: artworkUri!),
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
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
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
                        child: LyricsTimelineList(
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

class LyricsThemePalette {
  const LyricsThemePalette({
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

  factory LyricsThemePalette.fromTheme(BuildContext context) {
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
    return LyricsThemePalette(
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

class ArtworkFileImage extends StatelessWidget {
  const ArtworkFileImage({super.key, required this.uri});

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

class LyricsTimelineList extends StatefulWidget {
  const LyricsTimelineList({
    super.key,
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
  State<LyricsTimelineList> createState() => _LyricsTimelineListState();
}

class _LyricsTimelineListState extends State<LyricsTimelineList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = <int, GlobalKey>{};
  int _lastScrolledIndex = -1;

  @override
  void didUpdateWidget(covariant LyricsTimelineList oldWidget) {
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
