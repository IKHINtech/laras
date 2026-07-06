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
    await widget.store!.removeSongFromPlaylist(widget.playlistId!, song.id);
    setState(() => songs.removeAt(index));
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
    required this.onTap,
    this.trailing,
  });

  final Song song;
  final int index;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: song.artworkId == null
          ? const CircleAvatar(child: Icon(Icons.music_note))
          : QueryArtworkWidget(
              id: song.artworkId!,
              type: ArtworkType.AUDIO,
              nullArtworkWidget:
                  const CircleAvatar(child: Icon(Icons.music_note)),
            ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          Text(song.artistLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing ?? Text('${index + 1}'),
      onTap: onTap,
    );
  }
}
