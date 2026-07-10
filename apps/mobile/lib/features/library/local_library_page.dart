import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'playback_insights_page.dart';
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
  List<RecentPlaybackEntry> recentEntries = [];
  List<RecentPlaybackEntry> mostPlayedEntries = [];
  Set<String> favoriteIds = <String>{};
  bool loading = true;
  bool showCollapsedActions = false;
  String? _lastHistorySongId;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
    widget.player.addListener(_handlePlayerRefresh);
    _loadInitial();
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    widget.player.removeListener(_handlePlayerRefresh);
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

  void _handlePlayerRefresh() {
    final songId = widget.player.currentSong?.id;
    if (songId == null || songId == _lastHistorySongId) return;
    _lastHistorySongId = songId;
    _refreshPlaybackInsights();
  }

  Future<void> _loadInitial() async {
    final cachedSongs = await widget.store.loadLibrary();
    final favorites = await widget.store.loadFavorites();
    localSongs = cachedSongs;
    favoriteIds = favorites;
    await _refreshCollageSongs();
    await _refreshPlaybackInsights();
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _reloadFavorites() async {
    favoriteIds = await widget.store.loadFavorites();
    if (mounted) setState(() {});
  }

  Future<void> _refreshPlaybackInsights() async {
    recentEntries = await widget.store.loadRecentPlayedSongs(limit: 10);
    mostPlayedEntries = await widget.store.loadMostPlayedSongs(limit: 10);
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
      final l10n = AppLocalizations.of(context)!;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scannedLocalSongs(localSongs.length))),
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
    final l10n = AppLocalizations.of(context)!;
    final playlists = await widget.store.loadPlaylists();
    if (!mounted) return;
    if (playlists.isEmpty) {
      final nameController = TextEditingController(text: 'My Playlist');
      final created = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.createLocalPlaylist),
          content: TextField(
            controller: nameController,
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
                subtitle: Text(l10n.songsCount(playlist.songIds.length)),
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
    ).showSnackBar(
        SnackBar(content: Text(l10n.addedToPlaylist(selected.name))));
  }

  Widget _buildSongTile(Song song, List<Song> sourceSongs) {
    final l10n = AppLocalizations.of(context)!;
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
                    child: Text(
                      isFavorite ? l10n.removeFavorite : l10n.addFavorite,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'playlist',
                    child: Text(l10n.addToPlaylist),
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
    final l10n = AppLocalizations.of(context)!;
    if (loading) return const _LibraryLoadingList();
    if (songs.isEmpty) {
      return Center(
        child: Text(
          localSongs.isEmpty
              ? l10n.noLocalLibraryCache
              : l10n.noSongsMatchSearch,
        ),
      );
    }
    final showInsights = search.text.trim().isEmpty &&
        (recentEntries.isNotEmpty || mostPlayedEntries.isNotEmpty);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: songs.length + (showInsights ? 1 : 0),
      itemBuilder: (_, i) {
        if (showInsights && i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              children: [
                if (recentEntries.isNotEmpty)
                  _PlaybackPreviewSection(
                    title: l10n.recentlyPlayed,
                    subtitle: l10n.localRecentlyPlayedSubtitle,
                    entries: recentEntries.take(8).toList(),
                    emptyIcon: Icons.history,
                    onViewAll: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => PlaybackInsightsPage(
                              player: widget.player,
                              store: widget.store,
                              mode: PlaybackInsightsMode.recent,
                            ),
                          ),
                        )
                        .then((_) => _refreshPlaybackInsights()),
                    onPlayEntry: (entryIndex) => widget.player.playQueue(
                      recentEntries.map((entry) => entry.song).toList(),
                      entryIndex,
                    ),
                  ),
                if (recentEntries.isNotEmpty && mostPlayedEntries.isNotEmpty)
                  const SizedBox(height: 14),
                if (mostPlayedEntries.isNotEmpty)
                  _PlaybackPreviewSection(
                    title: l10n.mostPlayedLabel,
                    subtitle: l10n.localMostPlayedSubtitle,
                    entries: mostPlayedEntries.take(8).toList(),
                    emptyIcon: Icons.bar_chart_rounded,
                    showRank: true,
                    onViewAll: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => PlaybackInsightsPage(
                              player: widget.player,
                              store: widget.store,
                              mode: PlaybackInsightsMode.mostPlayed,
                            ),
                          ),
                        )
                        .then((_) => _refreshPlaybackInsights()),
                    onPlayEntry: (entryIndex) => widget.player.playQueue(
                      mostPlayedEntries.map((entry) => entry.song).toList(),
                      entryIndex,
                    ),
                  ),
              ],
            ),
          );
        }
        final songIndex = showInsights ? i - 1 : i;
        return _buildSongTile(songs[songIndex], songs);
      },
    );
  }

  Widget _buildBucketTab({
    required List<_GroupBucket> buckets,
    required IconData icon,
    required String emptyLabel,
  }) {
    if (loading) return const _LibraryLoadingList();
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
          subtitle: Text(
              AppLocalizations.of(context)!.songsCount(bucket.songs.length)),
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
            title: Text(AppLocalizations.of(context)!.localCollection),
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
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'scan',
                          child:
                              Text(AppLocalizations.of(context)!.rescanSongs),
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
                                    ? AppLocalizations.of(context)!
                                        .localLibraryEmptyHero
                                    : AppLocalizations.of(context)!
                                        .bucketSongsCached(localSongs.length),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed:
                                  filteredSongs.isEmpty ? null : _shuffleAll,
                              icon: const Icon(Icons.shuffle),
                              label: Text(
                                  AppLocalizations.of(context)!.shuffleAll),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: scan,
                              icon: const Icon(Icons.folder),
                              label:
                                  Text(AppLocalizations.of(context)!.scanText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: search,
                          focusNode: searchFocus,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText:
                                AppLocalizations.of(context)!.searchLibraryHint,
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.2,
                              ),
                            ),
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
              tabBar: TabBar(
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.songsTab),
                  Tab(text: AppLocalizations.of(context)!.artistsTab),
                  Tab(text: AppLocalizations.of(context)!.albumsTab),
                  Tab(text: AppLocalizations.of(context)!.foldersTab),
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
              emptyLabel: AppLocalizations.of(context)!.noArtistsFound,
            ),
            _buildBucketTab(
              buckets: albumBuckets,
              icon: Icons.album,
              emptyLabel: AppLocalizations.of(context)!.noAlbumsFound,
            ),
            _buildBucketTab(
              buckets: folderBuckets,
              icon: Icons.folder,
              emptyLabel: AppLocalizations.of(context)!.noFoldersFound,
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

class _LibraryLoadingList extends StatelessWidget {
  const _LibraryLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => const _LibraryLoadingTile(),
    );
  }
}

class _LibraryLoadingTile extends StatelessWidget {
  const _LibraryLoadingTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          const _ShimmerBox(
            width: 52,
            height: 52,
            borderRadius: 999,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                    width: double.infinity, height: 14, borderRadius: 8),
                SizedBox(height: 10),
                _ShimmerBox(width: 140, height: 12, borderRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _ShimmerBox(
            width: 22,
            height: 22,
            borderRadius: 999,
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final highlight = scheme.surface.withValues(alpha: 0.92);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final slide = (_controller.value * 2) - 1;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.8 + slide, -0.2),
                  end: Alignment(-0.8 + slide, 0.2),
                  colors: [
                    base,
                    highlight,
                    base,
                  ],
                  stops: const [0.15, 0.5, 0.85],
                ),
              ),
            );
          },
        ),
      ),
    );
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

class _PlaybackPreviewSection extends StatelessWidget {
  const _PlaybackPreviewSection({
    required this.title,
    required this.subtitle,
    required this.entries,
    required this.emptyIcon,
    required this.onViewAll,
    required this.onPlayEntry,
    this.showRank = false,
  });

  final String title;
  final String subtitle;
  final List<RecentPlaybackEntry> entries;
  final IconData emptyIcon;
  final VoidCallback onViewAll;
  final ValueChanged<int> onPlayEntry;
  final bool showRank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('Lihat semua')),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return SizedBox(
                width: 132,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onPlayEntry(index),
                  child: Ink(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 112,
                              height: 112,
                              child: _LibraryArtworkRect(
                                artworkId: entry.song.artworkId,
                                borderRadius: BorderRadius.circular(16),
                                fallback: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    emptyIcon,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.32),
                                  ),
                                ),
                              ),
                            ),
                            if (showRank)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.42),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '#${index + 1}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          entry.song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          showRank
                              ? '${entry.history.playCount}x diputar'
                              : entry.song.artistLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
    final l10n = AppLocalizations.of(context)!;
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
                            isFavorite ? l10n.removeFavorite : l10n.addFavorite,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'playlist',
                          child: Text(l10n.addToPlaylist),
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
      if (!mounted ||
          widget.artworkId != artworkId ||
          bytes == null ||
          bytes.isEmpty) {
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
      if (!mounted ||
          widget.artworkId != artworkId ||
          bytes == null ||
          bytes.isEmpty) {
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
