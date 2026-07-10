import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon_controller.dart';
import '../../core/auth_store.dart';
import '../../core/locale_controller.dart';
import '../../core/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../player/player_controller.dart';
import 'local_music_store.dart';
import 'server_auth_required_view.dart';
import 'server_dashboard_page.dart';
import 'server_library_page.dart';

class ServerHomePage extends StatefulWidget {
  const ServerHomePage({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.localeController,
    required this.appIconController,
    required this.store,
    required this.player,
  });

  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final LocaleController localeController;
  final AppIconController appIconController;
  final LocalMusicStore store;
  final PlayerController player;

  @override
  State<ServerHomePage> createState() => _ServerHomePageState();
}

class _ServerHomePageState extends State<ServerHomePage> {
  bool get isLoggedIn => widget.authStore.token != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!isLoggedIn) {
      return ServerAuthRequiredView(
        api: widget.api,
        authStore: widget.authStore,
        themeController: widget.themeController,
        localeController: widget.localeController,
        appIconController: widget.appIconController,
        store: widget.store,
        player: widget.player,
        onAuthChanged: () => setState(() {}),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: l10n.serverDashboard),
                  Tab(text: l10n.songsTab),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ServerDashboardPage(
                  api: widget.api,
                  authStore: widget.authStore,
                  player: widget.player,
                ),
                ServerLibraryPage(
                  api: widget.api,
                  authStore: widget.authStore,
                  player: widget.player,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
