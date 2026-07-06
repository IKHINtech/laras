import 'package:flutter/material.dart';

import '../../core/equalizer_bridge.dart';
import '../../core/theme_controller.dart';
import '../player/player_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.isLoggedIn,
    required this.player,
    required this.themeController,
    required this.onLogout,
  });

  final bool isLoggedIn;
  final PlayerController player;
  final ThemeController themeController;
  final Future<void> Function() onLogout;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _seedOptions = <Color>[
    Color(0xFF0B6E4F),
    Color(0xFF1565C0),
    Color(0xFFB3541E),
    Color(0xFFAD1457),
    Color(0xFF4E342E),
  ];

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_refresh);
    widget.themeController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.player.removeListener(_refresh);
    widget.themeController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _formatRemaining(Duration? duration) {
    if (duration == null) return 'Off';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  Future<void> _openEqualizer() async {
    final ok = await EqualizerBridge.openSystemEqualizer(
      widget.player.androidAudioSessionId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Opened Android equalizer'
              : 'Equalizer unavailable. Start playback first.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sleepRemaining = widget.player.sleepTimerRemaining;
    final theme = widget.themeController;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading:
              Icon(widget.isLoggedIn ? Icons.cloud_done : Icons.offline_bolt),
          title: Text(
              widget.isLoggedIn ? 'Server Mode aktif' : 'Local Mode aktif'),
          subtitle: Text(
            widget.isLoggedIn
                ? 'Kamu login ke Laras Server. Local player tetap bisa dipakai.'
                : 'Kamu memakai Laras tanpa login. Lagu, favorite, dan playlist lokal tersimpan di device.',
          ),
        ),
        const Divider(),
        Text('Theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {theme.themeMode},
          onSelectionChanged: (value) => theme.setThemeMode(value.first),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: _seedOptions
              .map(
                (color) => InkWell(
                  onTap: () => theme.setSeedColor(color),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.seedColor.toARGB32() == color.toARGB32()
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Text('Sleep Timer', style: Theme.of(context).textTheme.titleMedium),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('Stop playback automatically'),
          subtitle: Text('Remaining: ${_formatRemaining(sleepRemaining)}'),
          trailing: sleepRemaining == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.player.cancelSleepTimer,
                ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () =>
                  widget.player.setSleepTimer(const Duration(minutes: 15)),
              child: const Text('15 min'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  widget.player.setSleepTimer(const Duration(minutes: 30)),
              child: const Text('30 min'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  widget.player.setSleepTimer(const Duration(minutes: 60)),
              child: const Text('60 min'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.lyrics),
          title: const Text('Lyrics .lrc'),
          subtitle: const Text(
            'Now Playing auto-scan .lrc di folder lagu, cache path ke SQLite.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.equalizer),
          title: const Text('System Equalizer'),
          subtitle: const Text(
            'Buka equalizer Android bawaan bila device mendukung.',
          ),
          onTap: _openEqualizer,
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active),
          title: const Text('Background / Lock Screen'),
          subtitle: const Text(
            'Media service, notification control, dan media button sudah disiapkan di Android manifest.',
          ),
        ),
        const Divider(),
        if (widget.isLoggedIn)
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout from server'),
            subtitle:
                const Text('Tidak menghapus library/favorite/playlist lokal.'),
            onTap: widget.onLogout,
          )
        else
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tidak wajib login'),
            subtitle: Text(
                'Login hanya dibutuhkan saat ingin memakai server pribadi.'),
          ),
      ],
    );
  }
}
