import 'package:flutter/material.dart';

import 'local_music_store.dart';
import 'playback_insights_page.dart';

class ServerPlaybackPreviewSection extends StatelessWidget {
  const ServerPlaybackPreviewSection({
    super.key,
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
  final bool showRank;
  final VoidCallback onViewAll;
  final ValueChanged<int> onPlayEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
          ],
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.76),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(emptyIcon, size: 24),
                      const SizedBox(height: 8),
                      const Text('Belum ada data playback'),
                    ],
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entries.length > 8 ? 8 : entries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    return SizedBox(
                      width: 132,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => onPlayEntry(index),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.colorScheme.primary
                                                .withValues(alpha: 0.88),
                                            theme.colorScheme.secondary
                                                .withValues(alpha: 0.72),
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.graphic_eq_rounded,
                                        size: 46,
                                        color: theme.colorScheme.onPrimary
                                            .withValues(alpha: 0.92),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      right: 10,
                                      bottom: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.28,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          showRank
                                              ? '${entry.history.playCount}x diputar'
                                              : formatPlayedAt(
                                                  entry.history.playedAt,
                                                ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w700,
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
                                            color: Colors.black.withValues(
                                              alpha: 0.42,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            '#${index + 1}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
                                    ? entry.song.artistLabel
                                    : '${entry.history.playCount}x diputar',
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
