import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../l10n/app_localizations.dart';
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
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  bool searching = false;

  bool get editable => widget.playlistId != null && widget.store != null;
  List<Song> get visibleSongs {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return songs;
    return songs
        .where(
          (song) =>
              song.title.toLowerCase().contains(query) ||
              song.artistLabel.toLowerCase().contains(query) ||
              song.albumLabel.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    songs = [...widget.songs];
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  Future<void> _removeAt(int index) async {
    if (!editable) return;
    final song = songs[index];
    final confirmed = await _confirmRemoveSong(song);
    if (!confirmed) return;
    await widget.store!.removeSongFromPlaylist(widget.playlistId!, song.id);
    setState(() => songs.removeAt(index));
  }

  Future<void> _removeSong(Song song) async {
    final index = songs.indexWhere((item) => item.id == song.id);
    if (index < 0) return;
    await _removeAt(index);
  }

  Future<bool> _confirmRemoveSong(Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.removeSongFromPlaylistTitle),
        content: Text(l10n.removeSongFromPlaylistMessage(song.title)),
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

  Future<void> _playPlaylist() async {
    if (songs.isEmpty) return;
    await widget.player.playQueue(songs, 0);
  }

  void _startSearch() {
    setState(() => searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) searchFocus.requestFocus();
    });
  }

  void _stopSearch() {
    searchController.clear();
    searchFocus.unfocus();
    setState(() => searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleSongs = this.visibleSongs;
    final canReorder = editable && !searching && searchController.text.isEmpty;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            title: searching
                ? TextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchPlaylist,
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                  )
                : Text(widget.title),
            actions: [
              IconButton(
                tooltip: searching ? l10n.closeSearch : l10n.searchText,
                icon: Icon(searching ? Icons.close : Icons.search),
                onPressed: searching ? _stopSearch : _startSearch,
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _PlaylistHeader(
                title: widget.title,
                songs: songs,
                onPlay: songs.isEmpty ? null : _playPlaylist,
              ),
            ),
          ),
        ],
        body: songs.isEmpty
            ? Center(child: Text(l10n.playlistEmpty))
            : visibleSongs.isEmpty
                ? Center(child: Text(l10n.noSongsMatchSearch))
                : canReorder
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
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
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: visibleSongs.length,
                        itemBuilder: (_, index) {
                          final song = visibleSongs[index];
                          return _SongTile(
                            song: song,
                            index:
                                songs.indexWhere((item) => item.id == song.id),
                            player: widget.player,
                            onTap: () =>
                                widget.player.playQueue(visibleSongs, index),
                            trailing: editable
                                ? IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeSong(song),
                                  )
                                : null,
                          );
                        },
                      ),
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.title,
    required this.songs,
    required this.onPlay,
  });

  final String title;
  final List<Song> songs;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),
        Opacity(
          opacity: 0.22,
          child: _PlaylistHeaderCollage(songs: songs),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PlaylistHeaderCollage(songs: songs, compact: true),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${songs.length} songs',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: onPlay,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistHeaderCollage extends StatelessWidget {
  const _PlaylistHeaderCollage({
    required this.songs,
    this.compact = false,
  });

  final List<Song> songs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final artworkSongs = <Song>[];
    final seen = <int>{};
    for (final song in songs) {
      final artworkId = song.artworkId;
      if (artworkId == null || seen.contains(artworkId)) continue;
      seen.add(artworkId);
      artworkSongs.add(song);
      if (artworkSongs.length == 4) break;
    }

    final size = compact ? 116.0 : double.infinity;
    return SizedBox(
      width: compact ? size : null,
      height: compact ? size : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 24 : 0),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final song =
                index < artworkSongs.length ? artworkSongs[index] : null;
            return _PlaylistHeaderTile(song: song);
          },
        ),
      ),
    );
  }
}

class _PlaylistHeaderTile extends StatelessWidget {
  const _PlaylistHeaderTile({required this.song});

  final Song? song;

  @override
  Widget build(BuildContext context) {
    final artworkId = song?.artworkId;
    if (artworkId == null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.music_note),
      );
    }

    return QueryArtworkWidget(
      id: artworkId,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.music_note),
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
