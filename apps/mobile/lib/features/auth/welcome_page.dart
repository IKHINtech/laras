import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../core/theme_controller.dart';
import '../home_shell.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
  });

  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Laras',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Offline-first music player. Streaming server hanya fitur tambahan.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.offline_bolt),
                    label: const Text('Continue Offline'),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomeShell(
                          api: api,
                          authStore: authStore,
                          themeController: themeController,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Login to Laras Server'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          api: api,
                          authStore: authStore,
                          themeController: themeController,
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          api: api,
                          authStore: authStore,
                          themeController: themeController,
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
