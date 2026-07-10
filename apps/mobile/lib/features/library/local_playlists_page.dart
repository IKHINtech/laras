import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: 'My Playlist');
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.createLocalPlaylist),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.playlistName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.createText),
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deletePlaylistTitle),
        content: Text(l10n.deletePlaylistMessage(playlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteText),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoriteSongs = songs
        .where((song) => favoriteIds.contains(song.id.toString()))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.localPlaylistsIntro),
            ),
            FilledButton.icon(
              onPressed: createPlaylist,
              icon: const Icon(Icons.add),
              label: Text(l10n.playlistButton),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.recentlyPlayed),
            subtitle: Text(
              recentEntries.isEmpty
                  ? l10n.noPlayHistory
                  : l10n.recentSongsCount(recentEntries.length),
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
            title: Text(l10n.mostPlayedLabel),
            subtitle: Text(
              mostPlayedEntries.isEmpty
                  ? l10n.noPlayStats
                  : l10n.topSongsCount(mostPlayedEntries.length),
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
            title: Text(l10n.favoriteSongs),
            subtitle: Text(l10n.songsCount(favoriteSongs.length)),
            onTap: favoriteSongs.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LocalPlaylistDetailPage(
                          title: l10n.favoriteSongs,
                          songs: favoriteSongs,
                          player: widget.player,
                        ),
                      ),
                    ),
          ),
        ),
        const Divider(),
        if (playlists.isEmpty)
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(l10n.noLocalPlaylistYet),
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
                subtitle: Text(l10n.songsCount(playlistSongs.length)),
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
