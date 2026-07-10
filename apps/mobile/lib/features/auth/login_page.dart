import 'package:flutter/material.dart';
import '../../core/app_icon_controller.dart';
import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../core/locale_controller.dart';
import '../../core/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../home_shell.dart';
import '../library/local_music_store.dart';
import '../player/player_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.localeController,
    required this.appIconController,
    required this.localStore,
    required this.player,
    this.initialRegisterMode = false,
  });
  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final LocaleController localeController;
  final AppIconController appIconController;
  final LocalMusicStore localStore;
  final PlayerController player;
  final bool initialRegisterMode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  late bool registerMode;

  @override
  void initState() {
    super.initState();
    registerMode = widget.initialRegisterMode;
  }

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      final token = registerMode
          ? await widget.api.register(name.text, email.text, password.text)
          : await widget.api.login(email.text, password.text);
      await widget.authStore.saveToken(token);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeShell(
            api: widget.api,
            authStore: widget.authStore,
            themeController: widget.themeController,
            localeController: widget.localeController,
            appIconController: widget.appIconController,
            localStore: widget.localStore,
            player: widget.player,
            initialIndex: 1,
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginFailed(e.toString()))));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          registerMode ? l10n.registerServerAccount : l10n.loginServerAccount,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.larasServer,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginDescription,
                      ),
                      const SizedBox(height: 24),
                      if (registerMode)
                        TextField(
                          controller: name,
                          decoration: InputDecoration(
                            labelText: l10n.fieldName,
                          ),
                        ),
                      TextField(
                        controller: email,
                        decoration: InputDecoration(labelText: l10n.fieldEmail),
                      ),
                      TextField(
                        controller: password,
                        decoration: InputDecoration(
                          labelText: l10n.fieldPassword,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: loading ? null : submit,
                        child: Text(registerMode ? l10n.register : l10n.login),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => registerMode = !registerMode),
                        child: Text(
                          registerMode
                              ? l10n.alreadyHaveAccount
                              : l10n.dontHaveAccount,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
