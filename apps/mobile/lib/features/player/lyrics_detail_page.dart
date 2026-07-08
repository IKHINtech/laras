import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/share_bridge.dart';
import '../library/song.dart';
import 'lyrics_service.dart';
import 'player_controller.dart';

class LyricsDetailPage extends StatefulWidget {
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
  State<LyricsDetailPage> createState() => _LyricsDetailPageState();
}

class _LyricsDetailPageState extends State<LyricsDetailPage> {
  final Set<int> _selectedIndices = <int>{};
  bool _sharing = false;

  bool get _isSelectionMode => _selectedIndices.isNotEmpty;

  List<LyricLine> get _selectedLyrics {
    final indices = _selectedIndices.toList()..sort();
    return [
      for (final index in indices)
        if (index >= 0 && index < widget.lyrics.length) widget.lyrics[index],
    ];
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _clearSelection() {
    if (_selectedIndices.isEmpty) return;
    setState(_selectedIndices.clear);
  }

  Future<void> _shareSelectedLyrics() async {
    if (_selectedLyrics.isEmpty || _sharing) return;
    final config = await _showShareComposer();
    if (config == null || !mounted) return;
    setState(() => _sharing = true);
    try {
      final file = await _renderShareCard(config);
      final text = _selectedLyrics.map((line) => line.text).join('\n');
      final ok = await ShareBridge.shareImage(
        path: file.path,
        text: '${widget.song.title} • ${widget.song.artistLabel}\n\n$text',
      );
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka share sheet.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyiapkan gambar lirik untuk dibagikan.')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<_LyricsShareConfig?> _showShareComposer() {
    var selectedTheme = LyricsShareTheme.laras;
    var selectedFormat = LyricsShareFormat.square;
    return showModalBottomSheet<_LyricsShareConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final palette = selectedTheme.palette;
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: palette.outline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 32,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        20 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Preview share lirik',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: palette.foreground,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pilih tema card dan format export sebelum dibagikan.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: palette.foregroundMuted,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).maybePop(),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: palette.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _LyricsSharePreview(
                              song: widget.song,
                              artworkUri: widget.artworkUri,
                              lines: _selectedLyrics,
                              config: _LyricsShareConfig(
                                theme: selectedTheme,
                                format: selectedFormat,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Tema card',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: palette.foreground,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final theme in LyricsShareTheme.values)
                                  _ShareThemeChip(
                                    theme: theme,
                                    selected: theme == selectedTheme,
                                    onTap: () => setModalState(() {
                                      selectedTheme = theme;
                                    }),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Format export',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: palette.foreground,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final format in LyricsShareFormat.values)
                                  _ShareFormatChip(
                                    format: format,
                                    selected: format == selectedFormat,
                                    onTap: () => setModalState(() {
                                      selectedFormat = format;
                                    }),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => Navigator.of(context).pop(
                                  _LyricsShareConfig(
                                    theme: selectedTheme,
                                    format: selectedFormat,
                                  ),
                                ),
                                icon: const Icon(Icons.ios_share_rounded),
                                label: Text(
                                  selectedFormat == LyricsShareFormat.story
                                      ? 'Bagikan Story 9:16'
                                      : 'Bagikan Gambar',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<File> _renderShareCard(_LyricsShareConfig config) async {
    final boundaryKey = GlobalKey();
    final overlay = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: Transform.translate(
          offset: const Offset(-5000, 0),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: config.format.width,
              height: config.format.height,
              child: Material(
                type: MaterialType.transparency,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: LyricsShareCard(
                    song: widget.song,
                    artworkUri: widget.artworkUri,
                    lines: _selectedLyrics,
                    theme: config.theme,
                    format: config.format,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(overlay);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Share boundary not ready');
      }
      // The export widget is already laid out at 1080px wide, so using a
      // large pixelRatio here multiplies memory usage and can crash devices.
      final image = await boundary.toImage(pixelRatio: 1);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Empty share image');
      }
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/shared');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }
      final sanitized =
          widget.song.title.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_').toLowerCase();
      final file = File(
        '${shareDir.path}/lyrics_${config.format.name}_${sanitized}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } finally {
      overlay.remove();
    }
  }

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
          if (widget.artworkUri != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.16,
                child: ArtworkFileImage(uri: widget.artworkUri!),
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
                stream: widget.controller.player.positionStream,
                builder: (context, snapshot) {
                  final activeIndex =
                      _resolveActiveIndex(
                        snapshot.data ?? widget.controller.position,
                      );
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
                                  widget.song.title,
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
                                  widget.song.artistLabel,
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
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: _isSelectionMode
                                ? IconButton(
                                    onPressed: _sharing
                                        ? null
                                        : _shareSelectedLyrics,
                                    icon: _sharing
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.ios_share_rounded),
                                    color: Colors.white,
                                    tooltip: 'Bagikan lirik terpilih',
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      if (_isSelectionMode) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_selectedIndices.length} baris dipilih',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.86),
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearSelection,
                              child: const Text('Batal pilih'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (widget.source != null)
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
                              'Source: ${widget.source!.label}',
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
                          lyrics: widget.lyrics,
                          activeIndex: activeIndex,
                          foregroundColor: Colors.white,
                          fadedColor: Colors.white.withValues(alpha: 0.48),
                          centerActive: true,
                          selectedIndices: _selectedIndices,
                          onLineTap: _isSelectionMode ? _toggleSelection : null,
                          onLineLongPress: _toggleSelection,
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
    if (widget.lyrics.isEmpty) return -1;
    if (!widget.lyrics.any((line) => line.isTimed)) return -1;
    var active = 0;
    for (var i = 0; i < widget.lyrics.length; i++) {
      if (widget.lyrics[i].isTimed && widget.lyrics[i].at <= position) {
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

enum LyricsShareTheme {
  laras('Laras Night'),
  aurora('Aurora Glow'),
  daylight('Daylight Paper');

  const LyricsShareTheme(this.label);

  final String label;

  String get logoAsset {
    switch (this) {
      case LyricsShareTheme.laras:
        return 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png';
      case LyricsShareTheme.aurora:
        return 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground_neon.png';
      case LyricsShareTheme.daylight:
        return 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground_dark.png';
    }
  }

  LyricsSharePalette get palette {
    switch (this) {
      case LyricsShareTheme.laras:
        return const LyricsSharePalette(
          gradient: [Color(0xFF08060D), Color(0xFF15101D), Color(0xFF20172D)],
          overlay: [Color(0x14000000), Color(0x94000000)],
          badgeBackground: Color(0x1FFFFFFF),
          badgeForeground: Color(0xFF8B5CF6),
          foreground: Color(0xFFF8FAFC),
          foregroundMuted: Color(0xFFD7D3E6),
          accent: Color(0xFFF59E0B),
          surface: Color(0xFF120D19),
          outline: Color(0x26FFFFFF),
          glow: Color(0x408B5CF6),
        );
      case LyricsShareTheme.aurora:
        return const LyricsSharePalette(
          gradient: [Color(0xFF07121F), Color(0xFF122538), Color(0xFF3A2242)],
          overlay: [Color(0x10000000), Color(0x8A020617)],
          badgeBackground: Color(0x1AF8FAFC),
          badgeForeground: Color(0xFF7DD3FC),
          foreground: Color(0xFFF4F8FF),
          foregroundMuted: Color(0xFFD2E7F8),
          accent: Color(0xFFF9A8D4),
          surface: Color(0xFF0F1A28),
          outline: Color(0x2E7DD3FC),
          glow: Color(0x4038BDF8),
        );
      case LyricsShareTheme.daylight:
        return const LyricsSharePalette(
          gradient: [Color(0xFFF7F2FF), Color(0xFFF7E8F4), Color(0xFFFFF4E6)],
          overlay: [Color(0x00FFFFFF), Color(0x14FFFFFF)],
          badgeBackground: Color(0xCCFFFFFF),
          badgeForeground: Color(0xFF7C3AED),
          foreground: Color(0xFF1F1630),
          foregroundMuted: Color(0xFF645B78),
          accent: Color(0xFFEA580C),
          surface: Color(0xFFF8F1FF),
          outline: Color(0x1F1F1630),
          glow: Color(0x40F59E0B),
        );
    }
  }
}

enum LyricsShareFormat {
  square('Square', '1:1', 1080, 1080),
  story('Instagram Story', '9:16', 1080, 1920);

  const LyricsShareFormat(this.label, this.description, this.width, this.height);

  final String label;
  final String description;
  final double width;
  final double height;

  double get aspectRatio => width / height;
}

class LyricsSharePalette {
  const LyricsSharePalette({
    required this.gradient,
    required this.overlay,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.foreground,
    required this.foregroundMuted,
    required this.accent,
    required this.surface,
    required this.outline,
    required this.glow,
  });

  final List<Color> gradient;
  final List<Color> overlay;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color foreground;
  final Color foregroundMuted;
  final Color accent;
  final Color surface;
  final Color outline;
  final Color glow;
}

class _LyricsShareConfig {
  const _LyricsShareConfig({
    required this.theme,
    required this.format,
  });

  final LyricsShareTheme theme;
  final LyricsShareFormat format;
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
    this.selectedIndices = const <int>{},
    this.onLineTap,
    this.onLineLongPress,
  });

  final List<LyricLine> lyrics;
  final int activeIndex;
  final Color foregroundColor;
  final Color fadedColor;
  final bool centerActive;
  final Set<int> selectedIndices;
  final ValueChanged<int>? onLineTap;
  final ValueChanged<int>? onLineLongPress;

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
        final selected = widget.selectedIndices.contains(index);
        final key = _lineKeys.putIfAbsent(index, GlobalKey.new);
        return Container(
          key: key,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                )
              : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onLineTap == null ? null : () => widget.onLineTap!(index),
            onLongPress: () => widget.onLineLongPress?.call(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                widget.lyrics[index].text,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: active ? widget.foregroundColor : widget.fadedColor,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                      height: 1.18,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LyricsShareCard extends StatelessWidget {
  const LyricsShareCard({
    super.key,
    required this.song,
    required this.artworkUri,
    required this.lines,
    required this.theme,
    required this.format,
  });

  final Song song;
  final Uri? artworkUri;
  final List<LyricLine> lines;
  final LyricsShareTheme theme;
  final LyricsShareFormat format;

  @override
  Widget build(BuildContext context) {
    final palette = theme.palette;
    final lineText = lines.map((line) => line.text).join('\n');
    final story = format == LyricsShareFormat.story;
    final longestLineLength = lines.fold<int>(
      0,
      (max, line) => line.text.length > max ? line.text.length : max,
    );
    final lyricStyle = _resolveShareLyricsStyle(
      story: story,
      lineCount: lines.length,
      totalChars: lineText.length,
      longestLineLength: longestLineLength,
      color: palette.foreground,
    );
    return SizedBox(
      width: format.width,
      height: format.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette.gradient,
          ),
        ),
        child: Stack(
          children: [
            if (artworkUri != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.14,
                  child: ArtworkFileImage(uri: artworkUri!),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: palette.overlay,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                story ? 88 : 84,
                story ? 112 : 88,
                story ? 88 : 84,
                story ? 112 : 88,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: palette.badgeBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: palette.outline),
                    ),
                    child: Image.asset(
                      theme.logoAsset,
                      width: story ? 34 : 36,
                      height: story ? 34 : 36,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Text(
                        'L',
                        style: TextStyle(
                          color: palette.badgeForeground,
                          fontWeight: FontWeight.w700,
                          fontSize: story ? 26 : 28,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: story ? 68 : 48),
                  Expanded(
                    child: _ShareLyricsBlock(
                      text: lineText,
                      style: lyricStyle,
                      maxLines: story ? 14 : 10,
                      fadeColor: palette.gradient.last,
                    ),
                  ),
                  SizedBox(height: story ? 28 : 22),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: story ? 22 : 24,
                      vertical: story ? 16 : 18,
                    ),
                    decoration: BoxDecoration(
                      color: palette.badgeBackground,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: palette.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            color: palette.foreground,
                            fontSize: story ? 32 : 34,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          song.artistLabel,
                          style: TextStyle(
                            color: palette.accent,
                            fontSize: story ? 26 : 28,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: story ? 18 : 14),
                  Text(
                    story ? 'Instagram Story • ${format.description}' : 'Shared from Laras',
                    style: TextStyle(
                      color: palette.foregroundMuted,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _resolveShareLyricsStyle({
  required bool story,
  required int lineCount,
  required int totalChars,
  required int longestLineLength,
  required Color color,
}) {
  var fontSize = story ? 58.0 : 54.0;
  var height = 1.22;

  if (lineCount >= 4) fontSize -= 4;
  if (lineCount >= 6) fontSize -= 5;
  if (lineCount >= 8) fontSize -= 5;
  if (totalChars > 80) fontSize -= 4;
  if (totalChars > 120) fontSize -= 5;
  if (totalChars > 160) fontSize -= 5;
  if (longestLineLength > 16) fontSize -= 4;
  if (longestLineLength > 24) fontSize -= 4;
  if (longestLineLength > 32) fontSize -= 4;
  if (totalChars > 140 || longestLineLength > 24) {
    height = 1.16;
  }

  fontSize = fontSize.clamp(story ? 30.0 : 28.0, story ? 58.0 : 54.0);
  return TextStyle(
    color: color,
    fontSize: fontSize,
    height: height,
    fontWeight: FontWeight.w700,
  );
}

class _ShareLyricsBlock extends StatelessWidget {
  const _ShareLyricsBlock({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.fadeColor,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final Color fadeColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white.withValues(alpha: 0.92),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.72, 0.88, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.clip,
              style: style,
            ),
          ),
        );
      },
    );
  }
}

class _LyricsSharePreview extends StatelessWidget {
  const _LyricsSharePreview({
    required this.song,
    required this.artworkUri,
    required this.lines,
    required this.config,
  });

  final Song song;
  final Uri? artworkUri;
  final List<LyricLine> lines;
  final _LyricsShareConfig config;

  @override
  Widget build(BuildContext context) {
    final palette = config.theme.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.badgeBackground.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: config.format.aspectRatio,
              child: FittedBox(
                fit: BoxFit.cover,
                child: LyricsShareCard(
                  song: song,
                  artworkUri: artworkUri,
                  lines: lines,
                  theme: config.theme,
                  format: config.format,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareThemeChip extends StatelessWidget {
  const _ShareThemeChip({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final LyricsShareTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = theme.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? palette.accent : palette.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: palette.gradient),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              theme.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareFormatChip extends StatelessWidget {
  const _ShareFormatChip({
    required this.format,
    required this.selected,
    required this.onTap,
  });

  final LyricsShareFormat format;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.16)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.78)
                : scheme.outlineVariant.withValues(alpha: 0.42),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              format.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              format.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
