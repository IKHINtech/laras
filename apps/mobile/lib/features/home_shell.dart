import 'dart:async';

import 'package:flutter/material.dart';
import '../core/app_icon_controller.dart';
import '../core/home_widget_command_bus.dart';
import '../core/theme_controller.dart';
import '../core/api_client.dart';
import '../core/auth_store.dart';
import 'library/server_library_page.dart';
import 'library/local_library_page.dart';
import 'library/local_music_store.dart';
import 'library/local_playlists_page.dart';
import 'player/player_controller.dart';
import 'player/mini_player.dart';
import 'player/now_playing_page.dart';
import 'settings/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.appIconController,
    this.initialIndex = 0,
  });
  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final AppIconController appIconController;
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int index;
  late final PlayerController player;
  late final LocalMusicStore localStore;
  StreamSubscription<Uri>? _homeWidgetCommandSub;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    localStore = LocalMusicStore();
    player = PlayerController(store: localStore);
    _homeWidgetCommandSub = HomeWidgetCommandBus.stream.listen(
      _handleHomeWidgetCommand,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = HomeWidgetCommandBus.takePending();
      if (pending != null) {
        unawaited(_handleHomeWidgetCommand(pending));
      }
    });
  }

  @override
  void dispose() {
    _homeWidgetCommandSub?.cancel();
    player.close();
    super.dispose();
  }

  Future<void> _handleHomeWidgetCommand(Uri uri) async {
    if (uri.scheme != 'laras') return;
    await player.ready;

    switch (uri.host) {
      case 'now-playing':
        if (!mounted || player.currentSong == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NowPlayingPage(
              controller: player,
              store: localStore,
            ),
          ),
        );
        return;
      case 'player':
        final action = uri.queryParameters['action'];
        if (action == 'previous') {
          await player.previous();
        } else if (action == 'play-pause') {
          await player.playOrPause();
        } else if (action == 'next') {
          await player.next();
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showShellAppBar = index != 0;
    final pages = [
      LocalLibraryPage(player: player, store: localStore),
      ServerLibraryPage(
        api: widget.api,
        authStore: widget.authStore,
        themeController: widget.themeController,
        appIconController: widget.appIconController,
        player: player,
      ),
      LocalPlaylistsPage(player: player, store: localStore),
      SettingsPage(
        isLoggedIn: widget.authStore.token != null,
        api: widget.api,
        authStore: widget.authStore,
        player: player,
        themeController: widget.themeController,
        appIconController: widget.appIconController,
        onLogout: () async {
          await widget.authStore.clear();
          if (mounted) setState(() {});
        },
      ),
    ];

    return Scaffold(
      appBar: showShellAppBar
          ? AppBar(
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
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              reverseDuration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offset,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(index),
                child: pages[index],
              ),
            ),
          ),
          StreamBuilder(
            stream: player.player.sequenceStateStream,
            builder: (context, snapshot) {
              final hasMiniPlayer = player.currentSong != null;
              return AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.bottomCenter,
                child: hasMiniPlayer
                    ? MiniPlayer(controller: player, store: localStore)
                    : const SizedBox.shrink(),
              );
            },
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
