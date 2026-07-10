import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ServerDashboardSection extends StatelessWidget {
  const ServerDashboardSection({
    super.key,
    required this.totalSongs,
    required this.totalStorageBytes,
    required this.recentCount,
    required this.mostPlayedCount,
  });

  final int totalSongs;
  final int totalStorageBytes;
  final int recentCount;
  final int mostPlayedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                icon: Icons.library_music_rounded,
                label: l10n.totalSongsLabel,
                value: '$totalSongs',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                icon: Icons.storage_rounded,
                label: l10n.storageLabel,
                value: formatBytes(totalStorageBytes),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                icon: Icons.history,
                label: l10n.recentLabel,
                value: '$recentCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                icon: Icons.bar_chart_rounded,
                label: l10n.mostPlayedLabel,
                value: '$mostPlayedCount',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.secondary.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 18),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final fixed = value >= 10 || unitIndex == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$fixed ${units[unitIndex]}';
}
