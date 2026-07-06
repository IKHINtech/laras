import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'song.dart';

class LocalLibraryPage extends StatefulWidget {
  const LocalLibraryPage({
    super.key,
    required this.player,
    required this.store,
  });
  final PlayerController player;
  final LocalMusicStore store;

  @override
  State<LocalLibraryPage> createState() => _LocalLibraryPageState();
}

class _LocalLibraryPageState extends State<LocalLibraryPage> {
  static const _collapsedActionsOffset = 72.0;

  final query = OnAudioQuery();
  final search = TextEditingController();
  final searchFocus = FocusNode();
  final scrollController = ScrollController();
  List<Song> localSongs = [];
  Set<String> favoriteIds = <String>{};
  bool loading = false;
  bool showCollapsedActions = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    search.dispose();
    searchFocus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final next = scrollController.hasClients &&
        scrollController.offset >= _collapsedActionsOffset;
    if (next != showCollapsedActions && mounted) {
      setState(() => showCollapsedActions = next);
    }
  }

  Future<void> _loadInitial() async {
    final cachedSongs = await widget.store.loadLibrary();
    final favorites = await widget.store.loadFavorites();
    localSongs = cachedSongs;
    favoriteIds = favorites;
    if (mounted) setState(() {});
  }

  Future<void> _reloadFavorites() async {
    favoriteIds = await widget.store.loadFavorites();
    if (mounted) setState(() {});
  }

  Future<void> scan() async {
    setState(() => loading = true);
    final audioPermission = await Permission.audio.request();
    final storagePermission = await Permission.storage.request();
    if (!audioPermission.isGranted && !storagePermission.isGranted) {
      if (mounted) setState(() => loading = false);
      return;
    }

    final songs = await query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    localSongs = songs
        .map(_toAppSong)
        .where((song) => song.streamUrl.isNotEmpty)
        .toList();
    await widget.store.saveLibrary(localSongs);

    if (mounted) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned ${localSongs.length} local songs')),
      );
    }
  }

  Song _toAppSong(SongModel s) {
    final path = s.data;
    final normalized = path.replaceAll('\\', '/');
    final lastSlash = normalized.lastIndexOf('/');
    final folderPath = lastSlash >= 0 ? normalized.substring(0, lastSlash) : '';
    return Song(
      id: s.id.toString(),
      title: s.title,
      artist: s.artist ?? '',
      album: s.album ?? '',
      streamUrl: s.uri ?? s.data,
      durationMs: s.duration ?? 0,
      artworkId: s.id,
      folderPath: folderPath,
      filePath: path,
      isLocal: true,
    );
  }

  List<Song> get filteredSongs {
    final q = search.text.trim().toLowerCase();
    if (q.isEmpty) return localSongs;
    return localSongs.where((song) {
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q) ||
          song.album.toLowerCase().contains(q) ||
          song.folderLabel.toLowerCase().contains(q);
    }).toList();
  }

  List<_GroupBucket> _groupBy(String Function(Song song) labelOf) {
    final map = <String, List<Song>>{};
    for (final song in filteredSongs) {
      final label =
          labelOf(song).trim().isEmpty ? 'Unknown' : labelOf(song).trim();
      map.putIfAbsent(label, () => <Song>[]).add(song);
    }
    final buckets = map.entries
        .map((entry) => _GroupBucket(label: entry.key, songs: entry.value))
        .toList()
      ..sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    return buckets;
  }

  Future<void> toggleFavorite(Song song) async {
    await widget.store.toggleFavorite(song.id);
    await _reloadFavorites();
  }

  Future<void> addToPlaylist(Song song) async {
    final playlists = await widget.store.loadPlaylists();
    if (!mounted) return;
    if (playlists.isEmpty) {
      final nameController = TextEditingController(text: 'My Playlist');
      final created = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Create local playlist'),
          content: TextField(
            controller: nameController,
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
        await widget.store.createPlaylist(nameController.text);
        final fresh = await widget.store.loadPlaylists();
        if (fresh.isNotEmpty) {
          await widget.store.addSongToPlaylist(fresh.last.id, song.id);
        }
      }
      return;
    }

    final selected = await showModalBottomSheet<LocalPlaylist>(
      context: context,
      builder: (_) => ListView(
        children: playlists
            .map(
              (playlist) => ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(playlist.name),
                subtitle: Text('${playlist.songIds.length} songs'),
                onTap: () => Navigator.pop(context, playlist),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null) return;
    await widget.store.addSongToPlaylist(selected.id, song.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added to ${selected.name}')));
  }

  Widget _buildSongTile(Song song, List<Song> sourceSongs) {
    final isFavorite = favoriteIds.contains(song.id);
    return ListTile(
      leading: song.artworkId == null
          ? const CircleAvatar(child: Icon(Icons.music_note))
          : QueryArtworkWidget(
              id: song.artworkId!,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const CircleAvatar(
                child: Icon(Icons.music_note),
              ),
            ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        song.artistLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'favorite') toggleFavorite(song);
          if (value == 'playlist') addToPlaylist(song);
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'favorite',
            child: Text(isFavorite ? 'Remove favorite' : 'Add favorite'),
          ),
          const PopupMenuItem(
            value: 'playlist',
            child: Text('Add to playlist'),
          ),
        ],
      ),
      onTap: () =>
          widget.player.playQueue(sourceSongs, sourceSongs.indexOf(song)),
    );
  }

  Widget _buildSongsTab(List<Song> songs) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (songs.isEmpty) {
      return Center(
        child: Text(
          localSongs.isEmpty
              ? 'No local library cache yet. Tap Scan.'
              : 'No songs match search.',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: songs.length,
      itemBuilder: (_, i) => _buildSongTile(songs[i], songs),
    );
  }

  Widget _buildBucketTab({
    required List<_GroupBucket> buckets,
    required IconData icon,
    required String emptyLabel,
  }) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (buckets.isEmpty) return Center(child: Text(emptyLabel));
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: buckets.length,
      itemBuilder: (_, i) {
        final bucket = buckets[i];
        final coverSong = bucket.songs.first;
        return ListTile(
          leading: coverSong.artworkId == null
              ? CircleAvatar(child: Icon(icon))
              : QueryArtworkWidget(
                  id: coverSong.artworkId!,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: CircleAvatar(child: Icon(icon)),
                ),
          title: Text(
            bucket.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${bucket.songs.length} songs'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _BucketSongsPage(
                title: bucket.label,
                songs: bucket.songs,
                player: widget.player,
                favoriteIds: favoriteIds,
                onToggleFavorite: toggleFavorite,
                onAddToPlaylist: addToPlaylist,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final songs = filteredSongs;
    final artistBuckets = _groupBy((song) => song.artistLabel);
    final albumBuckets = _groupBy((song) => song.albumLabel);
    final folderBuckets = _groupBy((song) => song.folderLabel);

    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            title: const Text('Koleksi'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: showCollapsedActions
                ? [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        await scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        );
                        if (!mounted) return;
                        searchFocus.requestFocus();
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'scan') {
                          scan();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'scan',
                          child: Text('Scan ulang lagu'),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            snap: false,
            toolbarHeight: 0,
            expandedHeight: 148,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              localSongs.isEmpty
                                  ? 'Offline library empty. Scan device music first.'
                                  : '${localSongs.length} songs cached for offline browsing.',
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: scan,
                            icon: const Icon(Icons.folder),
                            label: const Text('Scan'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: search,
                      focusNode: searchFocus,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search songs, artist, album, folder',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              color: Theme.of(context).colorScheme.surface,
              tabBar: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Songs'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Folders'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: [
            _buildSongsTab(songs),
            _buildBucketTab(
              buckets: artistBuckets,
              icon: Icons.person,
              emptyLabel: 'No artists found.',
            ),
            _buildBucketTab(
              buckets: albumBuckets,
              icon: Icons.album,
              emptyLabel: 'No albums found.',
            ),
            _buildBucketTab(
              buckets: folderBuckets,
              icon: Icons.folder,
              emptyLabel: 'No folders found.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({
    required this.color,
    required this.tabBar,
  });

  final Color color;
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.color != color || oldDelegate.tabBar != tabBar;
  }
}

class _GroupBucket {
  const _GroupBucket({required this.label, required this.songs});

  final String label;
  final List<Song> songs;
}

class _BucketSongsPage extends StatelessWidget {
  const _BucketSongsPage({
    required this.title,
    required this.songs,
    required this.player,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
  });

  final String title;
  final List<Song> songs;
  final PlayerController player;
  final Set<String> favoriteIds;
  final Future<void> Function(Song song) onToggleFavorite;
  final Future<void> Function(Song song) onAddToPlaylist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (_, i) {
          final song = songs[i];
          final isFavorite = favoriteIds.contains(song.id);
          return ListTile(
            leading: song.artworkId == null
                ? const CircleAvatar(child: Icon(Icons.music_note))
                : QueryArtworkWidget(
                    id: song.artworkId!,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const CircleAvatar(
                      child: Icon(Icons.music_note),
                    ),
                  ),
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
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'favorite') onToggleFavorite(song);
                if (value == 'playlist') onAddToPlaylist(song);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'favorite',
                  child: Text(isFavorite ? 'Remove favorite' : 'Add favorite'),
                ),
                const PopupMenuItem(
                  value: 'playlist',
                  child: Text('Add to playlist'),
                ),
              ],
            ),
            onTap: () => player.playQueue(songs, i),
          );
        },
      ),
    );
  }
}
