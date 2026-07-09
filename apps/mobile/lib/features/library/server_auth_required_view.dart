import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon_controller.dart';
import '../../core/auth_store.dart';
import '../../core/theme_controller.dart';
import '../auth/login_page.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';

class ServerAuthRequiredView extends StatelessWidget {
  const ServerAuthRequiredView({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.appIconController,
    required this.store,
    required this.player,
    required this.onAuthChanged,
  });

  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final AppIconController appIconController;
  final LocalMusicStore store;
  final PlayerController player;
  final VoidCallback onAuthChanged;

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Server Mode belum aktif',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Local Mode tetap bisa dipakai tanpa login. Login hanya untuk upload, streaming, sync playlist/favorite, dan offline download dari server.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Login to Laras Server'),
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            api: api,
                            authStore: authStore,
                            themeController: themeController,
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
                  label: const Text('Register'),
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            api: api,
                            authStore: authStore,
                            themeController: themeController,
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
