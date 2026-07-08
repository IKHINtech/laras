import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../library/local_music_store.dart';
import 'player_controller.dart';
import 'now_playing_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.controller, required this.store});
  final PlayerController controller;
  final LocalMusicStore store;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: controller.player.playerStateStream,
      builder: (context, snapshot) {
        final song = controller.currentSong;
        if (song == null) return const SizedBox.shrink();
        final playing = snapshot.data?.playing ?? false;
        return Material(
          elevation: 10,
          child: ListTile(
            onTap: () => NowPlayingRoute.open(
              context,
              controller: controller,
              store: store,
            ),
            leading: _MiniPlayerArtwork(artworkId: song.artworkId),
            title: _MiniMarqueeText(
              text: song.title,
              paused: ModalRoute.of(context)?.isCurrent == false,
            ),
            subtitle: Text(
              song.artistLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed:
                      controller.hasPrevious ? controller.previous : null,
                ),
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: controller.playOrPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: controller.hasNext ? controller.next : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniPlayerArtwork extends StatefulWidget {
  const _MiniPlayerArtwork({required this.artworkId});

  final int? artworkId;

  @override
  State<_MiniPlayerArtwork> createState() => _MiniPlayerArtworkState();
}

class _MiniPlayerArtworkState extends State<_MiniPlayerArtwork> {
  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static final Map<int, Uint8List> _cache = <int, Uint8List>{};

  Uint8List? _artworkBytes;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant _MiniPlayerArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkId != widget.artworkId) {
      _artworkBytes = null;
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    final artworkId = widget.artworkId;
    if (artworkId == null) return;
    final cached = _cache[artworkId];
    if (cached != null) {
      setState(() => _artworkBytes = cached);
      return;
    }
    try {
      final bytes = await _audioQuery.queryArtwork(
        artworkId,
        ArtworkType.AUDIO,
        size: 200,
        quality: 70,
        format: ArtworkFormat.JPEG,
      );
      if (!mounted ||
          widget.artworkId != artworkId ||
          bytes == null ||
          bytes.isEmpty) {
        return;
      }
      _cache[artworkId] = bytes;
      setState(() => _artworkBytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _artworkBytes;
    if (widget.artworkId == null || bytes == null || bytes.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.music_note));
    }
    return CircleAvatar(backgroundImage: MemoryImage(bytes));
  }
}

class _MiniMarqueeText extends StatefulWidget {
  const _MiniMarqueeText({
    required this.text,
    required this.paused,
  });

  final String text;
  final bool paused;

  @override
  State<_MiniMarqueeText> createState() => _MiniMarqueeTextState();
}

class _MiniMarqueeTextState extends State<_MiniMarqueeText> {
  late final ScrollController _scrollController;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  @override
  void didUpdateWidget(covariant _MiniMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _startIfNeeded(reset: true),
      );
    }
    if (oldWidget.paused != widget.paused && !widget.paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
    }
  }

  Future<void> _startIfNeeded({bool reset = false}) async {
    if (!_scrollController.hasClients) return;
    if (widget.paused) return;

    if (reset) {
      _running = false;
      _scrollController.jumpTo(0);
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0 || _running) return;

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) return;

    _running = true;
    var forward = true;
    while (mounted && _scrollController.hasClients) {
      if (widget.paused) {
        _running = false;
        return;
      }

      final target = forward ? _scrollController.position.maxScrollExtent : 0.0;
      await _scrollController.animateTo(
        target,
        duration: const Duration(seconds: 8),
        curve: Curves.linear,
      );
      if (!mounted || !_scrollController.hasClients) return;
      await Future<void>.delayed(const Duration(milliseconds: 700));

      if (_scrollController.position.maxScrollExtent <= 0) {
        _running = false;
        return;
      }
      forward = !forward;
    }
    _running = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.08, 0.92, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ClipRect(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(
            widget.text,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
