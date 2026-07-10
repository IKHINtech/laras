import 'package:flutter/material.dart';

import '../../core/app_icon_controller.dart';
import '../../core/equalizer_bridge.dart';
import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../core/locale_controller.dart';
import '../../core/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../library/local_music_store.dart';
import '../auth/login_page.dart';
import '../player/player_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.isLoggedIn,
    required this.api,
    required this.authStore,
    required this.store,
    required this.player,
    required this.themeController,
    required this.localeController,
    required this.appIconController,
    required this.onLogout,
  });

  final bool isLoggedIn;
  final ApiClient api;
  final AuthStore authStore;
  final LocalMusicStore store;
  final PlayerController player;
  final ThemeController themeController;
  final LocaleController localeController;
  final AppIconController appIconController;
  final Future<void> Function() onLogout;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _seedOptions = <_ThemePaletteOption>[
    _ThemePaletteOption(
      palette: ThemePalette.larasDefault,
      color: ThemeController.defaultSeedColor,
    ),
    _ThemePaletteOption(
      palette: ThemePalette.oceanBlue,
      color: Color(0xFF1565C0),
    ),
    _ThemePaletteOption(
      palette: ThemePalette.burntOrange,
      color: Color(0xFFB3541E),
    ),
    _ThemePaletteOption(
      palette: ThemePalette.rosePink,
      color: Color(0xFFAD1457),
    ),
    _ThemePaletteOption(
      palette: ThemePalette.earthBrown,
      color: Color(0xFF4E342E),
    ),
  ];

  Future<void> _openSeedColorPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _SeedColorPickerDialog(
        initialColor: widget.themeController.seedColor,
        l10n: l10n,
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
    widget.localeController.addListener(_refresh);
    widget.appIconController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.player.removeListener(_refresh);
    widget.themeController.removeListener(_refresh);
    widget.localeController.removeListener(_refresh);
    widget.appIconController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _paletteLabel(AppLocalizations l10n, ThemePalette palette) {
    return switch (palette) {
      ThemePalette.larasDefault => l10n.paletteLarasDefault,
      ThemePalette.oceanBlue => l10n.paletteOceanBlue,
      ThemePalette.burntOrange => l10n.paletteBurntOrange,
      ThemePalette.rosePink => l10n.paletteRosePink,
      ThemePalette.earthBrown => l10n.paletteEarthBrown,
    };
  }

  String _iconLabel(AppLocalizations l10n, AppIconVariant variant) {
    return switch (variant) {
      AppIconVariant.defaultIcon => l10n.iconDefault,
      AppIconVariant.dark => l10n.iconDark,
      AppIconVariant.neon => l10n.iconNeon,
    };
  }

  String _iconDescription(AppLocalizations l10n, AppIconVariant variant) {
    return switch (variant) {
      AppIconVariant.defaultIcon => l10n.iconDefaultDescription,
      AppIconVariant.dark => l10n.iconDarkDescription,
      AppIconVariant.neon => l10n.iconNeonDescription,
    };
  }

  String _formatRemaining(AppLocalizations l10n, Duration? duration) {
    if (duration == null) return l10n.off;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return l10n.minutesSeconds(minutes, seconds.toString().padLeft(2, '0'));
  }

  Future<void> _openEqualizer() async {
    final ok = await EqualizerBridge.openSystemEqualizer(
      widget.player.androidAudioSessionId,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.equalizerOpened : l10n.equalizerUnavailable,
        ),
      ),
    );
  }

  Future<void> _changeAppIcon(AppIconVariant variant) async {
    final changed = await widget.appIconController.setVariant(variant);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed
              ? l10n.launcherIconSwitched(_iconLabel(l10n, variant))
              : l10n.launcherIconFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sleepRemaining = widget.player.sleepTimerRemaining;
    final theme = widget.themeController;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading:
              Icon(widget.isLoggedIn ? Icons.cloud_done : Icons.offline_bolt),
          title: Text(
            widget.isLoggedIn ? l10n.modeServerActive : l10n.modeLocalActive,
          ),
          subtitle: Text(
            widget.isLoggedIn
                ? l10n.modeServerSubtitle
                : l10n.modeLocalSubtitle,
          ),
        ),
        const Divider(),
        Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
          ],
          selected: {theme.themeMode},
          onSelectionChanged: (value) => theme.setThemeMode(value.first),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _seedOptions
              .map(
            (option) => InkWell(
              onTap: () => theme.setSeedColor(option.color),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 92,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.seedColor.toARGB32() == option.color.toARGB32()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.35),
                    width: theme.seedColor.toARGB32() == option.color.toARGB32()
                        ? 2
                        : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.seedColor.toARGB32() ==
                                  option.color.toARGB32()
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _paletteLabel(l10n, option.palette),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          )
              .followedBy([
            InkWell(
              onTap: _openSeedColorPicker,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 92,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
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
                    const SizedBox(height: 8),
                    Text(
                      l10n.paletteCustom,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ]).toList(),
        ),
        const SizedBox(height: 20),
        Text(l10n.appIcon, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppIconVariant.values
              .map(
                (variant) => _AppIconPreviewCard(
                  variant: variant,
                  selected: widget.appIconController.currentVariant == variant,
                  onTap: () => _changeAppIcon(variant),
                  label: _iconLabel(l10n, variant),
                  description: _iconDescription(l10n, variant),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'system', label: Text(l10n.languageSystem)),
            ButtonSegment(value: 'id', label: Text(l10n.languageIndonesian)),
            ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
          ],
          selected: {widget.localeController.currentCode},
          onSelectionChanged: (value) =>
              widget.localeController.setLocaleCode(value.first),
        ),
        const SizedBox(height: 20),
        Text(l10n.sleepTimer, style: Theme.of(context).textTheme.titleMedium),
        ListTile(
          leading: const Icon(Icons.timer),
          title: Text(l10n.stopPlaybackAutomatically),
          subtitle:
              Text(l10n.remaining(_formatRemaining(l10n, sleepRemaining))),
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
          title: Text(l10n.lyricsLrc),
          subtitle: Text(l10n.lyricsLrcDescription),
        ),
        ListTile(
          leading: const Icon(Icons.equalizer),
          title: Text(l10n.systemEqualizer),
          subtitle: Text(l10n.systemEqualizerDescription),
          onTap: _openEqualizer,
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active),
          title: Text(l10n.backgroundLockScreen),
          subtitle: Text(l10n.backgroundLockScreenDescription),
        ),
        const Divider(),
        if (!widget.isLoggedIn) ...[
          Text(l10n.account, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(l10n.loginToServer),
            subtitle: Text(l10n.loginToServerDescription),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  api: widget.api,
                  authStore: widget.authStore,
                  themeController: widget.themeController,
                  localeController: widget.localeController,
                  appIconController: widget.appIconController,
                  localStore: widget.store,
                  player: widget.player,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: Text(l10n.registerServerAccount),
            subtitle: Text(l10n.registerServerDescription),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  api: widget.api,
                  authStore: widget.authStore,
                  themeController: widget.themeController,
                  localeController: widget.localeController,
                  appIconController: widget.appIconController,
                  localStore: widget.store,
                  player: widget.player,
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
            title: Text(l10n.logoutFromServer),
            subtitle: Text(l10n.logoutFromServerDescription),
            onTap: widget.onLogout,
          )
        else
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.offlineStillPrimary),
            subtitle: Text(l10n.offlineStillPrimaryDescription),
          ),
      ],
    );
  }
}

class _ThemePaletteOption {
  const _ThemePaletteOption({
    required this.palette,
    required this.color,
  });

  final ThemePalette palette;
  final Color color;
}

enum ThemePalette {
  larasDefault,
  oceanBlue,
  burntOrange,
  rosePink,
  earthBrown,
}

class _AppIconPreviewCard extends StatelessWidget {
  const _AppIconPreviewCard({
    required this.variant,
    required this.selected,
    required this.onTap,
    required this.label,
    required this.description,
  });

  final AppIconVariant variant;
  final bool selected;
  final VoidCallback onTap;
  final String label;
  final String description;

  static const _previewAssetByVariant = <AppIconVariant, String>{
    AppIconVariant.defaultIcon:
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    AppIconVariant.dark:
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_dark.png',
    AppIconVariant.neon:
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_neon.png',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: theme.colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  _previewAssetByVariant[variant]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.textTheme.bodySmall?.color?.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeedColorPickerDialog extends StatefulWidget {
  const _SeedColorPickerDialog({
    required this.initialColor,
    required this.l10n,
  });

  final Color initialColor;
  final AppLocalizations l10n;

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
      title: Text(widget.l10n.pickThemeColor),
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
              label: widget.l10n.hue,
              value: _hsvColor.hue,
              max: 360,
              onChanged: (value) => setState(
                () => _hsvColor = _hsvColor.withHue(value),
              ),
            ),
            _ColorSlider(
              label: widget.l10n.saturation,
              value: _hsvColor.saturation,
              max: 1,
              onChanged: (value) => setState(
                () => _hsvColor = _hsvColor.withSaturation(value),
              ),
            ),
            _ColorSlider(
              label: widget.l10n.brightness,
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
          child: Text(widget.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(color),
          child: Text(widget.l10n.apply),
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
