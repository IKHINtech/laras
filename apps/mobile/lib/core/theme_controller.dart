import 'package:flutter/material.dart';

import 'app_settings_store.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._store);

  final AppSettingsStore _store;

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF0B6E4F);

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  Future<void> load() async {
    final settings = await _store.loadThemeSettings();
    _themeMode = settings.mode;
    _seedColor = Color(settings.seedColorValue);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _persist();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    await _persist();
  }

  Future<void> _persist() async {
    await _store.saveThemeSettings(
      AppThemeSettings(
        mode: _themeMode,
        seedColorValue: _seedColor.toARGB32(),
      ),
    );
    notifyListeners();
  }
}
