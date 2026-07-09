import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'playback_insights_page.dart';
import 'server_dashboard_section.dart';
import 'server_playback_insights_page.dart';
import 'server_playback_preview_section.dart';

class ServerDashboardPage extends StatefulWidget {
  const ServerDashboardPage({
    super.key,
    required this.api,
    required this.authStore,
    required this.player,
  });

  final ApiClient api;
  final AuthStore authStore;
  final PlayerController player;

  @override
  State<ServerDashboardPage> createState() => _ServerDashboardPageState();
}

class _ServerDashboardPageState extends State<ServerDashboardPage> {
  List<RecentPlaybackEntry> recentEntries = [];
  List<RecentPlaybackEntry> mostPlayedEntries = [];
  int totalSongs = 0;
  int totalStorageBytes = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final stats = await widget.api.stats();
      totalSongs = (stats['total_songs'] as num?)?.toInt() ?? 0;
      totalStorageBytes = (stats['total_storage_bytes'] as num?)?.toInt() ?? 0;
      recentEntries = await widget.api.recentPlayedSongs(limit: 10);
      mostPlayedEntries = await widget.api.mostPlayedSongs(limit: 10);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> upload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;
    setState(() => loading = true);
    try {
      await widget.api.uploadSong(File(result.files.single.path!));
      await load();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Server Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: upload,
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ServerDashboardSection(
            totalSongs: totalSongs,
            totalStorageBytes: totalStorageBytes,
            recentCount: recentEntries.length,
            mostPlayedCount: mostPlayedEntries.length,
          ),
          if (recentEntries.isNotEmpty) ...[
            const SizedBox(height: 16),
            ServerPlaybackPreviewSection(
              title: 'Recently Played',
              subtitle: 'Lagu server yang baru kamu putar',
              entries: recentEntries,
              emptyIcon: Icons.history,
              onViewAll: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => ServerPlaybackInsightsPage(
                        api: widget.api,
                        authStore: widget.authStore,
                        player: widget.player,
                        mode: PlaybackInsightsMode.recent,
                      ),
                    ),
                  )
                  .then((_) => load()),
              onPlayEntry: (entryIndex) => widget.player.playQueue(
                recentEntries.map((entry) => entry.song).toList(),
                entryIndex,
                token: widget.authStore.token,
              ),
            ),
          ],
          if (recentEntries.isNotEmpty && mostPlayedEntries.isNotEmpty)
            const SizedBox(height: 14),
          if (mostPlayedEntries.isNotEmpty)
            ServerPlaybackPreviewSection(
              title: 'Most Played',
              subtitle: 'Lagu server yang paling sering kamu putar',
              entries: mostPlayedEntries,
              emptyIcon: Icons.bar_chart_rounded,
              showRank: true,
              onViewAll: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => ServerPlaybackInsightsPage(
                        api: widget.api,
                        authStore: widget.authStore,
                        player: widget.player,
                        mode: PlaybackInsightsMode.mostPlayed,
                      ),
                    ),
                  )
                  .then((_) => load()),
              onPlayEntry: (entryIndex) => widget.player.playQueue(
                mostPlayedEntries.map((entry) => entry.song).toList(),
                entryIndex,
                token: widget.authStore.token,
              ),
            ),
          if (recentEntries.isEmpty && mostPlayedEntries.isEmpty) ...[
            const SizedBox(height: 24),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada playback server. Mulai putar lagu server dulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
