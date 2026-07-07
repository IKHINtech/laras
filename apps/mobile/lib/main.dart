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

class _LarasAppState extends State<LarasApp> {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
}
