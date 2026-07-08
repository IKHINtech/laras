import 'package:flutter/material.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'local_playlist_detail_page.dart';
import 'playback_insights_page.dart';
import 'song.dart';

class LocalPlaylistsPage extends StatefulWidget {
  const LocalPlaylistsPage({
    super.key,
    required this.player,
    required this.store,
  });
  final PlayerController player;
  final LocalMusicStore store;

  @override
  State<LocalPlaylistsPage> createState() => _LocalPlaylistsPageState();
}

class _LocalPlaylistsPageState extends State<LocalPlaylistsPage> {
  List<LocalPlaylist> playlists = [];
  List<Song> songs = [];
  Set<String> favoriteIds = <String>{};
  List<RecentPlaybackEntry> recentEntries = [];
  List<RecentPlaybackEntry> mostPlayedEntries = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    playlists = await widget.store.loadPlaylists();
    favoriteIds = await widget.store.loadFavorites();
    songs = await widget.store.loadLibrary();
    recentEntries = await widget.store.loadRecentPlayedSongs(limit: 20);
    mostPlayedEntries = await widget.store.loadMostPlayedSongs(limit: 20);
    if (mounted) setState(() {});
  }

  Future<void> createPlaylist() async {
    final controller = TextEditingController(text: 'My Playlist');
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create local playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (created == true) {
      await widget.store.createPlaylist(controller.text);
      await load();
    }
  }

  Future<bool> _confirmDeletePlaylist(LocalPlaylist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus playlist?'),
        content: Text(
          'Playlist "${playlist.name}" akan dihapus dari device ini.',
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

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = songs
        .where((song) => favoriteIds.contains(song.id.toString()))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Local favorite dan playlist tersimpan di device, tanpa login.',
              ),
            ),
            FilledButton.icon(
              onPressed: createPlaylist,
              icon: const Icon(Icons.add),
              label: const Text('Playlist'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Recently Played'),
            subtitle: Text(
              recentEntries.isEmpty
                  ? 'Belum ada riwayat putar'
                  : '${recentEntries.length} lagu terakhir',
            ),
            onTap: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => PlaybackInsightsPage(
                      player: widget.player,
                      store: widget.store,
                      mode: PlaybackInsightsMode.recent,
                    ),
                  ),
                )
                .then((_) => load()),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Most Played'),
            subtitle: Text(
              mostPlayedEntries.isEmpty
                  ? 'Belum ada statistik putar'
                  : '${mostPlayedEntries.length} lagu teratas',
            ),
            onTap: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => PlaybackInsightsPage(
                      player: widget.player,
                      store: widget.store,
                      mode: PlaybackInsightsMode.mostPlayed,
                    ),
                  ),
                )
                .then((_) => load()),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorite Songs'),
            subtitle: Text('${favoriteSongs.length} songs'),
            onTap: favoriteSongs.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LocalPlaylistDetailPage(
                          title: 'Favorite Songs',
                          songs: favoriteSongs,
                          player: widget.player,
                        ),
                      ),
                    ),
          ),
        ),
        const Divider(),
        if (playlists.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Belum ada playlist lokal. Buat playlist atau tambahkan lagu dari tab Local.',
              ),
            ),
          )
        else
          ...playlists.map((playlist) {
            final playlistSongs = songs
                .where(
                  (song) => playlist.songIds.contains(song.id.toString()),
                )
                .toList();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(playlist.name),
                subtitle: Text('${playlistSongs.length} songs'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await _confirmDeletePlaylist(playlist);
                    if (!confirmed) return;
                    await widget.store.deletePlaylist(playlist.id);
                    await load();
                  },
                ),
                onTap: playlistSongs.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LocalPlaylistDetailPage(
                              title: playlist.name,
                              songs: playlistSongs,
                              player: widget.player,
                              playlistId: playlist.id,
                              store: widget.store,
                            ),
                          ),
                        ),
              ),
            );
          }),
      ],
    );
  }
}
