import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../library/local_music_store.dart';
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
  bool dragging = false;
  double dragValueMs = 0;
  List<LyricLine> lyrics = const <LyricLine>[];
  String? loadedSongId;
  PlaybackHistory? history;

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
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadLyrics() async {
    final song = widget.controller.currentSong;
    loadedSongId = song?.id;
    if (song == null) {
      lyrics = const <LyricLine>[];
      history = null;
      if (mounted) setState(() {});
      return;
    }
    lyrics = await lyricsService.loadLyrics(song, widget.store);
    history = await widget.store.loadPlaybackHistory(song.id);
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

    final duration = widget.controller.duration;
    final position = dragging
        ? Duration(milliseconds: dragValueMs.round())
        : widget.controller.position;
    final maxMs =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final activeLyricIndex = _activeLyricIndex(position);
    final remaining = duration - position;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => _QueueSheet(controller: widget.controller),
            ),
          ),
        ],
      ),
      body: SafeArea(
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: song.artworkId == null
                            ? Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.music_note, size: 96),
                              )
                            : QueryArtworkWidget(
                                id: song.artworkId!,
                                type: ArtworkType.AUDIO,
                                artworkFit: BoxFit.cover,
                                nullArtworkWidget: Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: const Icon(Icons.music_note, size: 96),
                                ),
                              ),
                      ),
                    ),
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
                    _MetaChip(
                      icon: Icons.access_time,
                      label:
                          '-${_format(remaining.isNegative ? Duration.zero : remaining)}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Slider(
                  value: position.inMilliseconds
                      .clamp(0, maxMs.toInt())
                      .toDouble(),
                  max: maxMs,
                  onChanged: (value) => setState(() {
                    dragging = true;
                    dragValueMs = value;
                  }),
                  onChangeEnd: (value) async {
                    dragging = false;
                    dragValueMs = value;
                    await widget.controller
                        .seek(Duration(milliseconds: value.round()));
                  },
                ),
                Row(
                  children: [
                    Text(_format(position)),
                    const Spacer(),
                    Text(_format(duration)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
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
                        widget.controller.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
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
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.controller.currentIndex + 1} / ${widget.controller.queue.length} in queue',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _LyricsPanel(
                    lyrics: lyrics,
                    activeIndex: activeLyricIndex,
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
    var active = 0;
    for (var i = 0; i < lyrics.length; i++) {
      if (lyrics[i].at <= position) {
        active = i;
      } else {
        break;
      }
    }
    return active;
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

class _LyricsPanel extends StatelessWidget {
  const _LyricsPanel({required this.lyrics, required this.activeIndex});

  final List<LyricLine> lyrics;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    if (lyrics.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('No .lrc lyrics found')),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lyrics.length,
        itemBuilder: (_, index) {
          final active = index == activeIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              lyrics[index].text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: active ? FontWeight.bold : FontWeight.w400,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        },
      ),
    );
  }
}
