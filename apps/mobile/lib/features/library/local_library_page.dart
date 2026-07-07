import 'dart:typed_data';

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
  List<Song> collageSongs = [];
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
    await _refreshCollageSongs();
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
    await _refreshCollageSongs();

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

  Future<void> _refreshCollageSongs() async {
    final candidates =
        localSongs.where((song) => song.artworkId != null).toList();
    final selected = <Song>[];
    final seenArtworkIds = <int>{};

    for (final song in candidates) {
      final artworkId = song.artworkId;
      if (artworkId == null || seenArtworkIds.contains(artworkId)) continue;

      final bytes = await query.queryArtwork(
        artworkId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 200,
        quality: 40,
      );

      if (bytes != null && bytes.isNotEmpty) {
        selected.add(song);
        seenArtworkIds.add(artworkId);
      }

      if (selected.length == 4) break;
    }

    collageSongs = selected;
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

  Future<void> _shuffleAll() async {
    final songs = filteredSongs;
    if (songs.isEmpty) return;
    final queue = [...songs]..shuffle();
    await widget.player.playQueue(queue, 0);
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
    final leadingArtwork = _LibraryArtworkAvatar(
      artworkId: song.artworkId,
      fallbackIcon: Icons.music_note,
    );
    return AnimatedBuilder(
      animation: widget.player,
      child: leadingArtwork,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isCurrent = widget.player.currentSong?.id == song.id;
        final activeColor = theme.colorScheme.primary;
        return ListTile(
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
              _NowPlayingIndicator(player: widget.player, songId: song.id),
              PopupMenuButton<String>(
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
            ],
          ),
          onTap: () =>
              widget.player.playQueue(sourceSongs, sourceSongs.indexOf(song)),
        );
      },
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
          leading: _LibraryArtworkAvatar(
            artworkId: coverSong.artworkId,
            fallbackIcon: icon,
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _ArtworkCollageBackground(songs: collageSongs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.15),
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                localSongs.isEmpty
                                    ? 'Offline library empty. Scan device music first.'
                                    : '${localSongs.length} songs cached for offline browsing.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed:
                                  filteredSongs.isEmpty ? null : _shuffleAll,
                              icon: const Icon(Icons.shuffle),
                              label: const Text('Shuffle All'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: scan,
                              icon: const Icon(Icons.folder),
                              label: const Text('Scan'),
                            ),
                          ],
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
                ],
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

class _ArtworkCollageBackground extends StatelessWidget {
  const _ArtworkCollageBackground({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    final covers =
        songs.where((song) => song.artworkId != null).take(4).toList();
    if (covers.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.55),
              Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: 0.35),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.library_music,
            size: 72,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      );
    }

    final tiles = List<Song?>.generate(
      4,
      (index) => index < covers.length ? covers[index] : null,
    );

    return Opacity(
      opacity: 0.2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gap = 8.0;
            final tileWidth = (constraints.maxWidth - (gap * 3)) / 4;
            final tileHeight = constraints.maxHeight * 0.55;
            final topOffsets = <double>[8, 0, 12, 4];
            final rotations = <double>[-0.08, 0.05, -0.04, 0.07];

            return Stack(
              children: [
                for (var i = 0; i < 4; i++)
                  _CollageTile(
                    song: tiles[i],
                    left: i * (tileWidth + gap),
                    top: topOffsets[i],
                    width: tileWidth,
                    height: tileHeight,
                    rotation: rotations[i],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CollageTile extends StatelessWidget {
  const _CollageTile({
    required this.song,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.rotation,
  });

  final Song? song;
  final double left;
  final double top;
  final double width;
  final double height;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: rotation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: song == null
              ? Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                )
              : _LibraryArtworkRect(
                  artworkId: song!.artworkId,
                  borderRadius: BorderRadius.circular(18),
                  fallback: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                  ),
                ),
        ),
      ),
    );
  }
}

class _GroupBucket {
  const _GroupBucket({required this.label, required this.songs});

  final String label;
  final List<Song> songs;
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
          padding: const EdgeInsets.only(right: 4),
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
          final leadingArtwork = _LibraryArtworkAvatar(
            artworkId: song.artworkId,
            fallbackIcon: Icons.music_note,
          );
          return AnimatedBuilder(
            animation: player,
            child: leadingArtwork,
            builder: (context, child) {
              final theme = Theme.of(context);
              final isCurrent = player.currentSong?.id == song.id;
              final activeColor = theme.colorScheme.primary;
              return ListTile(
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
                        : theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.78,
                          ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NowPlayingIndicator(player: player, songId: song.id),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'favorite') onToggleFavorite(song);
                        if (value == 'playlist') onAddToPlaylist(song);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'favorite',
                          child: Text(
                            isFavorite ? 'Remove favorite' : 'Add favorite',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'playlist',
                          child: Text('Add to playlist'),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () => player.playQueue(songs, i),
              );
            },
          );
        },
      ),
    );
  }
}

class _LibraryArtworkStore {
  static final OnAudioQuery query = OnAudioQuery();
  static final Map<int, Uint8List> cache = <int, Uint8List>{};
}

class _LibraryArtworkAvatar extends StatefulWidget {
  const _LibraryArtworkAvatar({
    required this.artworkId,
    required this.fallbackIcon,
  });

  final int? artworkId;
  final IconData fallbackIcon;

  @override
  State<_LibraryArtworkAvatar> createState() => _LibraryArtworkAvatarState();
}

class _LibraryArtworkAvatarState extends State<_LibraryArtworkAvatar> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LibraryArtworkAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkId != widget.artworkId) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final artworkId = widget.artworkId;
    if (artworkId == null) return;
    final cached = _LibraryArtworkStore.cache[artworkId];
    if (cached != null) {
      setState(() => _bytes = cached);
      return;
    }
    try {
      final bytes = await _LibraryArtworkStore.query.queryArtwork(
        artworkId,
        ArtworkType.AUDIO,
        size: 200,
        quality: 70,
        format: ArtworkFormat.JPEG,
      );
      if (!mounted || widget.artworkId != artworkId || bytes == null || bytes.isEmpty) {
        return;
      }
      _LibraryArtworkStore.cache[artworkId] = bytes;
      setState(() => _bytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (widget.artworkId == null || bytes == null || bytes.isEmpty) {
      return CircleAvatar(child: Icon(widget.fallbackIcon));
    }
    return CircleAvatar(backgroundImage: MemoryImage(bytes));
  }
}

class _LibraryArtworkRect extends StatefulWidget {
  const _LibraryArtworkRect({
    required this.artworkId,
    required this.borderRadius,
    required this.fallback,
  });

  final int? artworkId;
  final BorderRadius borderRadius;
  final Widget fallback;

  @override
  State<_LibraryArtworkRect> createState() => _LibraryArtworkRectState();
}

class _LibraryArtworkRectState extends State<_LibraryArtworkRect> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LibraryArtworkRect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkId != widget.artworkId) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final artworkId = widget.artworkId;
    if (artworkId == null) return;
    final cached = _LibraryArtworkStore.cache[artworkId];
    if (cached != null) {
      setState(() => _bytes = cached);
      return;
    }
    try {
      final bytes = await _LibraryArtworkStore.query.queryArtwork(
        artworkId,
        ArtworkType.AUDIO,
        size: 320,
        quality: 60,
        format: ArtworkFormat.JPEG,
      );
      if (!mounted || widget.artworkId != artworkId || bytes == null || bytes.isEmpty) {
        return;
      }
      _LibraryArtworkStore.cache[artworkId] = bytes;
      setState(() => _bytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (widget.artworkId == null || bytes == null || bytes.isEmpty) {
      return widget.fallback;
    }
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Image(
        image: MemoryImage(bytes),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}
