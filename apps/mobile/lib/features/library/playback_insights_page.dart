import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../player/player_controller.dart';
import 'local_music_store.dart';

enum PlaybackInsightsMode { recent, mostPlayed }

class PlaybackInsightsPage extends StatefulWidget {
  const PlaybackInsightsPage({
    super.key,
    required this.player,
    required this.store,
    required this.mode,
  });

  final PlayerController player;
  final LocalMusicStore store;
  final PlaybackInsightsMode mode;

  @override
  State<PlaybackInsightsPage> createState() => _PlaybackInsightsPageState();
}

class _PlaybackInsightsPageState extends State<PlaybackInsightsPage> {
  List<RecentPlaybackEntry> entries = [];
  bool loading = true;

  bool get isRecent => widget.mode == PlaybackInsightsMode.recent;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    entries = isRecent
        ? await widget.store.loadRecentPlayedSongs(limit: 100)
        : await widget.store.loadMostPlayedSongs(limit: 100);
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isRecent ? 'Hapus Recently Played?' : 'Reset Most Played?'),
        content: const Text(
          'Riwayat pemutaran lokal akan dihapus dari device ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.store.clearPlaybackHistory();
    if (!mounted) return;
    setState(() => entries = []);
  }

  String _formatPlayedAt(DateTime playedAt) {
    final diff = DateTime.now().difference(playedAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    final weeks = diff.inDays ~/ 7;
    if (weeks < 5) return '$weeks minggu lalu';
    final months = diff.inDays ~/ 30;
    if (months < 12) return '$months bulan lalu';
    final years = diff.inDays ~/ 365;
    return '$years tahun lalu';
  }

  @override
  Widget build(BuildContext context) {
    final title = isRecent ? 'Recently Played' : 'Most Played';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      isRecent
                          ? 'Belum ada riwayat putar. Mulai putar lagu lokal dulu.'
                          : 'Belum ada data lagu yang paling sering diputar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    return AnimatedBuilder(
                      animation: widget.player,
                      child: _RecentArtwork(artworkId: entry.song.artworkId),
                      builder: (context, child) {
                        final theme = Theme.of(context);
                        final isCurrent =
                            widget.player.currentSong?.id == entry.song.id;
                        final activeColor = theme.colorScheme.primary;
                        final subtitle = isRecent
                            ? '${entry.song.artistLabel} • ${_formatPlayedAt(entry.history.playedAt)} • ${entry.history.playCount}x diputar'
                            : '${entry.song.artistLabel} • ${entry.history.playCount}x diputar • terakhir ${_formatPlayedAt(entry.history.playedAt)}';
                        return ListTile(
                          tileColor: isCurrent
                              ? activeColor.withValues(alpha: 0.10)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: child,
                          title: Text(
                            entry.song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent ? activeColor : null,
                              fontWeight:
                                  isCurrent ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent
                                  ? activeColor.withValues(alpha: 0.82)
                                  : theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.78),
                            ),
                          ),
                          trailing: !isRecent
                              ? Text(
                                  '#${index + 1}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: activeColor.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                          onTap: () => widget.player.playQueue(
                            entries.map((e) => e.song).toList(),
                            index,
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class _RecentArtwork extends StatefulWidget {
  const _RecentArtwork({required this.artworkId});

  final int? artworkId;

  @override
  State<_RecentArtwork> createState() => _RecentArtworkState();
}

class _RecentArtworkState extends State<_RecentArtwork> {
  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static final Map<int, Uint8List> _cache = <int, Uint8List>{};

  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _RecentArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkId != widget.artworkId) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final artworkId = widget.artworkId;
    if (artworkId == null) return;
    final cached = _cache[artworkId];
    if (cached != null) {
      setState(() => _bytes = cached);
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
      setState(() => _bytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (widget.artworkId == null || bytes == null || bytes.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.history));
    }
    return CircleAvatar(backgroundImage: MemoryImage(bytes));
  }
}
