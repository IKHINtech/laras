import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'playback_insights_page.dart';

class ServerPlaybackInsightsPage extends StatefulWidget {
  const ServerPlaybackInsightsPage({
    super.key,
    required this.api,
    required this.authStore,
    required this.player,
    required this.mode,
  });

  final ApiClient api;
  final AuthStore authStore;
  final PlayerController player;
  final PlaybackInsightsMode mode;

  @override
  State<ServerPlaybackInsightsPage> createState() =>
      _ServerPlaybackInsightsPageState();
}

class _ServerPlaybackInsightsPageState
    extends State<ServerPlaybackInsightsPage> {
  List<RecentPlaybackEntry> entries = [];
  bool loading = true;

  bool get isRecent => widget.mode == PlaybackInsightsMode.recent;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      entries = isRecent
          ? await widget.api.recentPlayedSongs(limit: 100)
          : await widget.api.mostPlayedSongs(limit: 100);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isRecent ? 'Recently Played' : 'Most Played';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: load,
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
                          ? 'Belum ada riwayat putar server. Mulai putar lagu server dulu.'
                          : 'Belum ada data lagu server yang paling sering diputar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    itemBuilder: (_, index) {
                      final entry = entries[index];
                      return AnimatedBuilder(
                        animation: widget.player,
                        builder: (context, child) {
                          final theme = Theme.of(context);
                          final isCurrent =
                              widget.player.currentSong?.id == entry.song.id;
                          final activeColor = theme.colorScheme.primary;
                          final subtitle = isRecent
                              ? '${entry.song.artistLabel} • ${formatPlayedAt(entry.history.playedAt)} • ${entry.history.playCount}x diputar'
                              : '${entry.song.artistLabel} • ${entry.history.playCount}x diputar • terakhir ${formatPlayedAt(entry.history.playedAt)}';
                          return ListTile(
                            tileColor: isCurrent
                                ? activeColor.withValues(alpha: 0.10)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: activeColor.withValues(
                                alpha: 0.12,
                              ),
                              child: Icon(
                                isRecent
                                    ? Icons.history
                                    : Icons.bar_chart_rounded,
                                color: activeColor,
                              ),
                            ),
                            title: Text(
                              entry.song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrent ? activeColor : null,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color:
                                          activeColor.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                            onTap: () => widget.player.playQueue(
                              entries.map((e) => e.song).toList(),
                              index,
                              token: widget.authStore.token,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
