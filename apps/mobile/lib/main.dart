import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/app_icon_controller.dart';
import 'core/app_settings_store.dart';
import 'core/api_client.dart';
import 'core/auth_store.dart';
import 'core/home_widget_command_bus.dart';
import 'core/theme_controller.dart';
import 'features/auth/welcome_page.dart';
import 'features/home_shell.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(_homeWidgetBackgroundCallback);
  HomeWidget.initiallyLaunchedFromHomeWidget().then(HomeWidgetCommandBus.emit);
  HomeWidget.widgetClicked.listen(HomeWidgetCommandBus.emit);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'id.my.sarikhin.laras.audio',
    androidNotificationChannelName: 'Laras Playback',
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: false,
    preloadArtwork: true,
    androidNotificationIcon: 'drawable/ic_stat_laras',
  );
  final authStore = AuthStore();
  await authStore.load();
  final appSettingsStore = AppSettingsStore();
  final themeController = ThemeController(appSettingsStore);
  await themeController.load();
  final appIconController = AppIconController(appSettingsStore);
  await appIconController.load();
  runApp(
    LarasApp(
      authStore: authStore,
      themeController: themeController,
      appIconController: appIconController,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _homeWidgetBackgroundCallback(Uri? uri) async {
  HomeWidgetCommandBus.emit(uri);
}

class LarasApp extends StatefulWidget {
  const LarasApp({
    super.key,
    required this.authStore,
    required this.themeController,
    required this.appIconController,
  });
  final AuthStore authStore;
  final ThemeController themeController;
  final AppIconController appIconController;

  @override
  State<LarasApp> createState() => _LarasAppState();
}

class _WidgetRouteSink extends StatefulWidget {
  const _WidgetRouteSink();

  @override
  State<_WidgetRouteSink> createState() => _WidgetRouteSinkState();
}

class _WidgetRouteSinkState extends State<_WidgetRouteSink> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _LarasAppState extends State<LarasApp> {
  static const _larasAmber = Color(0xFFF59E0B);
  static const _larasBackground = Color(0xFF08060D);
  static const _larasSurface = Color(0xFF15101D);
  static const _larasSurfaceHigh = Color(0xFF20172D);
  static const _larasText = Color(0xFFF8FAFC);
  static const _larasTextSecondary = Color(0xFFA7A3B8);

  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient(baseUrl: apiBaseUrl, authStore: widget.authStore);
    widget.themeController.addListener(_refresh);
    widget.appIconController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_refresh);
    widget.appIconController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final seed = widget.themeController.seedColor;
    return MaterialApp(
      title: 'Laras',
      debugShowCheckedModeBanner: false,
      themeMode: widget.themeController.themeMode,
      theme: _buildTheme(seed: seed, brightness: Brightness.light),
      darkTheme: _buildTheme(seed: seed, brightness: Brightness.dark),
      onGenerateRoute: _onGenerateRoute,
      home:
          widget.authStore.token == null && !widget.authStore.hasSeenOfflineHome
              ? WelcomePage(
                  api: api,
                  authStore: widget.authStore,
                  themeController: widget.themeController,
                  appIconController: widget.appIconController,
                )
              : HomeShell(
                  api: api,
                  authStore: widget.authStore,
                  themeController: widget.themeController,
                  appIconController: widget.appIconController,
                  initialIndex: 0,
                ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final uri = _decodeWidgetRoute(settings.name);
    if (uri != null) {
      HomeWidgetCommandBus.emit(uri);
      return PageRouteBuilder<void>(
        settings: settings,
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const _WidgetRouteSink(),
      );
    }

    return PageRouteBuilder<void>(
      settings: settings,
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => const _WidgetRouteSink(),
    );
  }

  Uri? _decodeWidgetRoute(String? raw) {
    if (raw == null || raw.isEmpty || raw == '/') return null;
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    final action = uri.queryParameters['action'];
    if (action != null && action.isNotEmpty) {
      return Uri(
        scheme: 'laras',
        host: 'player',
        queryParameters: {'action': action},
      );
    }
    if (uri.path.contains('now-playing')) {
      return Uri(scheme: 'laras', host: 'now-playing');
    }
    return null;
  }

  ThemeData _buildTheme({
    required Color seed,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final scheme = isDark
        ? base.copyWith(
            primary: seed,
            onPrimary: _larasText,
            secondary: _larasAmber,
            onSecondary: _larasBackground,
            tertiary: _larasAmber,
            surface: _larasSurface,
            onSurface: _larasText,
            surfaceContainerLowest: _larasBackground,
            surfaceContainerLow: _larasSurface,
            surfaceContainer: _larasSurface,
            surfaceContainerHigh: _larasSurfaceHigh,
            surfaceContainerHighest: _larasSurfaceHigh,
            onSurfaceVariant: _larasTextSecondary,
            outline: seed.withValues(alpha: 0.35),
            outlineVariant: _larasTextSecondary.withValues(alpha: 0.20),
            primaryContainer: seed.withValues(alpha: 0.22),
            onPrimaryContainer: _larasText,
            secondaryContainer: _larasAmber.withValues(alpha: 0.16),
            onSecondaryContainer: _larasText,
            scrim: Colors.black,
            shadow: Colors.black,
          )
        : base.copyWith(
            primary: seed,
            secondary: _larasAmber,
            tertiary: _larasAmber,
          );

    final theme = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: isDark ? _larasBackground : null,
      canvasColor: isDark ? _larasBackground : null,
      dividerColor: isDark
          ? _larasTextSecondary.withValues(alpha: 0.16)
          : null,
      textTheme: ThemeData(
        brightness: brightness,
        useMaterial3: true,
      ).textTheme.apply(
        bodyColor: isDark ? _larasText : null,
        displayColor: isDark ? _larasText : null,
      ),
    );

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? _larasBackground : scheme.surface,
        foregroundColor: isDark ? _larasText : scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? _larasSurface : scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? _larasTextSecondary.withValues(alpha: 0.10)
                : scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? _larasSurface : scheme.surface,
        indicatorColor: isDark
            ? _larasAmber.withValues(alpha: 0.22)
            : scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected
                ? (isDark ? _larasAmber : scheme.primary)
                : (isDark ? _larasTextSecondary : scheme.onSurfaceVariant),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? (isDark ? _larasAmber : scheme.primary)
                : (isDark ? _larasTextSecondary : scheme.onSurfaceVariant),
          );
        }),
      ),
      chipTheme: theme.chipTheme.copyWith(
        backgroundColor: isDark ? _larasSurfaceHigh : scheme.surfaceContainer,
        selectedColor: isDark
            ? seed.withValues(alpha: 0.24)
            : scheme.secondaryContainer,
        side: BorderSide(
          color: isDark
              ? _larasTextSecondary.withValues(alpha: 0.14)
              : scheme.outlineVariant.withValues(alpha: 0.30),
        ),
        labelStyle: TextStyle(
          color: isDark ? _larasText : scheme.onSurface,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? _larasAmber : scheme.primary,
        textColor: isDark ? _larasText : scheme.onSurface,
      ),
    );
  }
}
