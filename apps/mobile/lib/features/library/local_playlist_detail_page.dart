import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'song.dart';

class LocalPlaylistDetailPage extends StatefulWidget {
  const LocalPlaylistDetailPage({
    super.key,
    required this.title,
    required this.songs,
    required this.player,
    this.playlistId,
    this.store,
  });

  final String title;
  final List<Song> songs;
  final PlayerController player;
  final String? playlistId;
  final LocalMusicStore? store;

  @override
  State<LocalPlaylistDetailPage> createState() =>
      _LocalPlaylistDetailPageState();
}

class _LocalPlaylistDetailPageState extends State<LocalPlaylistDetailPage> {
  late List<Song> songs;

  bool get editable => widget.playlistId != null && widget.store != null;

  @override
  void initState() {
    super.initState();
    songs = [...widget.songs];
  }

  Future<void> _removeAt(int index) async {
    if (!editable) return;
    final song = songs[index];
    final confirmed = await _confirmRemoveSong(song);
    if (!confirmed) return;
    await widget.store!.removeSongFromPlaylist(widget.playlistId!, song.id);
    setState(() => songs.removeAt(index));
  }

  Future<bool> _confirmRemoveSong(Song song) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus lagu dari playlist?'),
        content: Text(
          '"${song.title}" akan dihapus dari playlist ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (!editable) return;
    final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final item = songs.removeAt(oldIndex);
    songs.insert(adjustedIndex, item);
    setState(() {});
    await widget.store!.reorderPlaylistSongs(
      widget.playlistId!,
      oldIndex,
      newIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: songs.isEmpty
          ? const Center(child: Text('Playlist empty'))
          : editable
              ? ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: songs.length,
                  onReorderItem: _reorder,
                  itemBuilder: (_, index) {
                    final song = songs[index];
                    return _SongTile(
                      key: ValueKey(song.id),
                      song: song,
                      index: index,
                      player: widget.player,
                      onTap: () => widget.player.playQueue(songs, index),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeAt(index),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (_, index) => _SongTile(
                    song: songs[index],
                    index: index,
                    player: widget.player,
                    onTap: () => widget.player.playQueue(songs, index),
                  ),
                ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    super.key,
    required this.song,
    required this.index,
    required this.player,
    required this.onTap,
    this.trailing,
  });

  final Song song;
  final int index;
  final PlayerController player;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final leadingArtwork = _PlaylistArtwork(artworkId: song.artworkId);
    return AnimatedBuilder(
      animation: player,
      child: leadingArtwork,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isCurrent = player.currentSong?.id == song.id;
        final activeColor = theme.colorScheme.primary;
        return ListTile(
          key: key,
          tileColor: isCurrent
              ? activeColor.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: child,
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent ? activeColor : null,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            song.artistLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent
                  ? activeColor.withValues(alpha: 0.82)
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.78),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NowPlayingIndicator(player: player, songId: song.id),
              trailing ?? Text('${index + 1}'),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }
}

class _PlaylistArtwork extends StatefulWidget {
  const _PlaylistArtwork({required this.artworkId});

  final int? artworkId;

  @override
  State<_PlaylistArtwork> createState() => _PlaylistArtworkState();
}

class _PlaylistArtworkState extends State<_PlaylistArtwork> {
  static final OnAudioQuery _audioQuery = OnAudioQuery();

  Uint8List? _artworkBytes;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant _PlaylistArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkId != widget.artworkId) {
      _artworkBytes = null;
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    final artworkId = widget.artworkId;
    if (artworkId == null) return;
    try {
      final bytes = await _audioQuery.queryArtwork(
        artworkId,
        ArtworkType.AUDIO,
        size: 200,
        quality: 70,
        format: ArtworkFormat.JPEG,
      );
      if (!mounted || widget.artworkId != artworkId) return;
      setState(() => _artworkBytes = bytes);
    } catch (_) {
      if (!mounted || widget.artworkId != artworkId) return;
      setState(() => _artworkBytes = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _artworkBytes;
    if (widget.artworkId == null || bytes == null || bytes.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.music_note));
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(bytes),
    );
  }
}

class _NowPlayingIndicator extends StatelessWidget {
  const _NowPlayingIndicator({
    required this.player,
    required this.songId,
  });

  final PlayerController player;
  final String songId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: player,
      builder: (context, child) {
        final isCurrent = player.currentSong?.id == songId;
        if (!isCurrent) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: 18,
            height: 18,
            child: player.isPlaying
                ? _EqualizerGlyph(
                    color: theme.colorScheme.primary,
                    phase: player.position.inMilliseconds ~/ 180,
                  )
                : Icon(
                    Icons.pause_circle,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
          ),
        );
      },
    );
  }
}

class _EqualizerGlyph extends StatelessWidget {
  const _EqualizerGlyph({
    required this.color,
    required this.phase,
  });

  final Color color;
  final int phase;

  @override
  Widget build(BuildContext context) {
    final patterns = <List<double>>[
      [0.35, 0.9, 0.55],
      [0.8, 0.45, 0.95],
      [0.55, 0.85, 0.4],
      [0.95, 0.6, 0.75],
    ];
    final heights = patterns[phase % patterns.length];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 3,
            height: 14 * heights[i],
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (i != heights.length - 1) const SizedBox(width: 2),
        ],
      ],
    );
  }
}
