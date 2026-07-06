import 'package:flutter/material.dart';
import '../core/theme_controller.dart';
import '../core/api_client.dart';
import '../core/auth_store.dart';
import 'library/server_library_page.dart';
import 'library/local_library_page.dart';
import 'library/local_music_store.dart';
import 'library/local_playlists_page.dart';
import 'player/player_controller.dart';
import 'player/mini_player.dart';
import 'settings/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    this.initialIndex = 0,
  });
  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int index;
  late final PlayerController player;
  late final LocalMusicStore localStore;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    localStore = LocalMusicStore();
    player = PlayerController(store: localStore);
  }

  @override
  void dispose() {
    player.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      LocalLibraryPage(player: player, store: localStore),
      ServerLibraryPage(
        api: widget.api,
        authStore: widget.authStore,
        themeController: widget.themeController,
        player: player,
      ),
      LocalPlaylistsPage(player: player, store: localStore),
      SettingsPage(
        isLoggedIn: widget.authStore.token != null,
        player: player,
        themeController: widget.themeController,
        onLogout: () async {
          await widget.authStore.clear();
          if (mounted) setState(() {});
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laras'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(
                widget.authStore.token == null
                    ? Icons.offline_bolt
                    : Icons.cloud_done,
                size: 18,
              ),
              label: Text(
                widget.authStore.token == null ? 'Offline' : 'Server',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: pages[index]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(controller: player, store: localStore),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music),
            label: 'Local',
          ),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Server'),
          NavigationDestination(
            icon: Icon(Icons.queue_music),
            label: 'Playlists',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
