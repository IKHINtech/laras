import 'package:flutter/material.dart';

import '../../core/app_icon_controller.dart';
import '../../core/equalizer_bridge.dart';
import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../core/theme_controller.dart';
import '../auth/login_page.dart';
import '../player/player_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.isLoggedIn,
    required this.api,
    required this.authStore,
    required this.player,
    required this.themeController,
    required this.appIconController,
    required this.onLogout,
  });

  final bool isLoggedIn;
  final ApiClient api;
  final AuthStore authStore;
  final PlayerController player;
  final ThemeController themeController;
  final AppIconController appIconController;
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

  Future<void> _openSeedColorPicker() async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _SeedColorPickerDialog(
        initialColor: widget.themeController.seedColor,
      ),
    );
    if (picked == null) return;
    await widget.themeController.setSeedColor(picked);
  }

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_refresh);
    widget.themeController.addListener(_refresh);
    widget.appIconController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.player.removeListener(_refresh);
    widget.themeController.removeListener(_refresh);
    widget.appIconController.removeListener(_refresh);
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

  Future<void> _changeAppIcon(AppIconVariant variant) async {
    final changed = await widget.appIconController.setVariant(variant);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed
              ? 'Launcher icon switched to ${variant.label}.'
              : 'Gagal mengganti icon launcher.',
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
          runSpacing: 10,
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
              .followedBy([
            InkWell(
              onTap: _openSeedColorPicker,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.cyan,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ]).toList(),
        ),
        const SizedBox(height: 20),
        Text('App Icon', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<AppIconVariant>(
            groupValue: widget.appIconController.currentVariant,
            onChanged: (value) {
              if (value != null) {
                _changeAppIcon(value);
              }
            },
            child: Column(
              children: AppIconVariant.values
                  .map(
                    (variant) => RadioListTile<AppIconVariant>(
                      value: variant,
                      title: Text(variant.label),
                      subtitle: Text(
                        switch (variant) {
                          AppIconVariant.defaultIcon => 'Icon standar Laras',
                          AppIconVariant.dark => 'Versi gelap dan lebih subtle',
                          AppIconVariant.neon =>
                            'Versi cerah dengan aksen neon',
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
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
            'Now Playing prioritaskan .lrc, lalu fallback ke metadata lyric bila tersedia.',
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
        if (!widget.isLoggedIn) ...[
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login to Laras Server'),
            subtitle: const Text(
              'Gunakan server pribadi untuk upload, stream, dan sync.',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  api: widget.api,
                  authStore: widget.authStore,
                  themeController: widget.themeController,
                  appIconController: widget.appIconController,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Register Server Account'),
            subtitle: const Text('Buat akun server pribadi Laras.'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  api: widget.api,
                  authStore: widget.authStore,
                  themeController: widget.themeController,
                  appIconController: widget.appIconController,
                  initialRegisterMode: true,
                ),
              ),
            ),
          ),
          const Divider(),
        ],
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
            title: Text('Offline tetap utama'),
            subtitle: Text(
              'Server login hanya fitur tambahan dan bisa diakses kapan saja dari Settings.',
            ),
          ),
      ],
    );
  }
}

class _SeedColorPickerDialog extends StatefulWidget {
  const _SeedColorPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_SeedColorPickerDialog> createState() => _SeedColorPickerDialogState();
}

class _SeedColorPickerDialogState extends State<_SeedColorPickerDialog> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    final color = _hsvColor.toColor();
    return AlertDialog(
      title: const Text('Pilih warna tema'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            _ColorSlider(
              label: 'Hue',
              value: _hsvColor.hue,
              max: 360,
              onChanged: (value) => setState(
                () => _hsvColor = _hsvColor.withHue(value),
              ),
            ),
            _ColorSlider(
              label: 'Saturation',
              value: _hsvColor.saturation,
              max: 1,
              onChanged: (value) => setState(
                () => _hsvColor = _hsvColor.withSaturation(value),
              ),
            ),
            _ColorSlider(
              label: 'Brightness',
              value: _hsvColor.value,
              max: 1,
              onChanged: (value) => setState(
                () => _hsvColor = _hsvColor.withValue(value),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(color),
          child: const Text('Pakai'),
        ),
      ],
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalized =
        max == 1 ? value.toStringAsFixed(2) : value.round().toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            Text(normalized, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value.clamp(0, max),
          min: 0,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
