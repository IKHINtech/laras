import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/app_settings_store.dart';
import 'core/api_client.dart';
import 'core/auth_store.dart';
import 'core/theme_controller.dart';
import 'features/auth/welcome_page.dart';
import 'features/home_shell.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'id.my.sarikhin.laras.audio',
    androidNotificationChannelName: 'Laras Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: false,
    preloadArtwork: true,
  );
  final authStore = AuthStore();
  await authStore.load();
  final themeController = ThemeController(AppSettingsStore());
  await themeController.load();
  runApp(LarasApp(authStore: authStore, themeController: themeController));
}

class LarasApp extends StatefulWidget {
  const LarasApp({
    super.key,
    required this.authStore,
    required this.themeController,
  });
  final AuthStore authStore;
  final ThemeController themeController;

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
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_refresh);
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
      home: widget.authStore.token == null
          ? WelcomePage(
              api: api,
              authStore: widget.authStore,
              themeController: widget.themeController,
            )
          : HomeShell(
              api: api,
              authStore: widget.authStore,
              themeController: widget.themeController,
              initialIndex: 0,
            ),
    );
  }
}
