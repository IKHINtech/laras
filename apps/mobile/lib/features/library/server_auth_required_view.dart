import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon_controller.dart';
import '../../core/auth_store.dart';
import '../../core/locale_controller.dart';
import '../../core/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_page.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';

class ServerAuthRequiredView extends StatelessWidget {
  const ServerAuthRequiredView({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.localeController,
    required this.appIconController,
    required this.store,
    required this.player,
    required this.onAuthChanged,
  });

  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final LocaleController localeController;
  final AppIconController appIconController;
  final LocalMusicStore store;
  final PlayerController player;
  final VoidCallback onAuthChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56),
                const SizedBox(height: 12),
                Text(
                  l10n.modeServerActive,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginDescription,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.login),
                  label: Text(l10n.loginToServer),
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            api: api,
                            authStore: authStore,
                            themeController: themeController,
                            localeController: localeController,
                            appIconController: appIconController,
                            localStore: store,
                            player: player,
                          ),
                        ),
                      )
                      .then((_) => onAuthChanged()),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: Text(l10n.register),
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            api: api,
                            authStore: authStore,
                            themeController: themeController,
                            localeController: localeController,
                            appIconController: appIconController,
                            localStore: store,
                            player: player,
                            initialRegisterMode: true,
                          ),
                        ),
                      )
                      .then((_) => onAuthChanged()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
