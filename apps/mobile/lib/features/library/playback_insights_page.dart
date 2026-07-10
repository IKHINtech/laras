import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isRecent ? l10n.clearRecentPlayedTitle : l10n.clearMostPlayedTitle,
        ),
        content: Text(l10n.clearLocalPlaybackWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteText),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.store.clearPlaybackHistory();
    if (!mounted) return;
    setState(() => entries = []);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = isRecent ? l10n.recentlyPlayed : l10n.mostPlayedLabel;
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
                          ? l10n.noRecentPlayedDetail
                          : l10n.noMostPlayedDetail,
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
                            ? l10n.recentPlaybackSubtitle(
                                entry.song.artistLabel,
                                formatPlayedAt(l10n, entry.history.playedAt),
                                entry.history.playCount,
                              )
                            : l10n.mostPlayedSubtitle(
                                entry.song.artistLabel,
                                entry.history.playCount,
                                formatPlayedAt(l10n, entry.history.playedAt),
                              );
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
                                  l10n.rankLabel(index + 1),
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

String formatPlayedAt(AppLocalizations l10n, DateTime playedAt) {
  final diff = DateTime.now().difference(playedAt);
  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
  final weeks = diff.inDays ~/ 7;
  if (weeks < 5) return l10n.weeksAgo(weeks);
  final months = diff.inDays ~/ 30;
  if (months < 12) return l10n.monthsAgo(months);
  final years = diff.inDays ~/ 365;
  return l10n.yearsAgo(years);
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
