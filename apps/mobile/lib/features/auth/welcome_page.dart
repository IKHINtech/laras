import 'package:flutter/material.dart';
import '../../core/app_icon_controller.dart';
import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../core/locale_controller.dart';
import '../../core/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../home_shell.dart';
import '../library/local_music_store.dart';
import 'login_page.dart';
import '../player/player_controller.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.localeController,
    required this.appIconController,
    required this.localStore,
    required this.player,
  });

  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final LocaleController localeController;
  final AppIconController appIconController;
  final LocalMusicStore localStore;
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.music_note, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.welcomeTagline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.offline_bolt),
                    label: Text(l10n.continueOffline),
                    onPressed: () async {
                      await authStore.markOfflineHomeSeen();
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => HomeShell(
                            api: api,
                            authStore: authStore,
                            themeController: themeController,
                            localeController: localeController,
                            appIconController: appIconController,
                            localStore: localStore,
                            player: player,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.login),
                    label: Text(l10n.loginToServer),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          api: api,
                          authStore: authStore,
                          themeController: themeController,
                          localeController: localeController,
                          appIconController: appIconController,
                          localStore: localStore,
                          player: player,
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: Text(l10n.register),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          api: api,
                          authStore: authStore,
                          themeController: themeController,
                          localeController: localeController,
                          appIconController: appIconController,
                          localStore: localStore,
                          player: player,
                          initialRegisterMode: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
