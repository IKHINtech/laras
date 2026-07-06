import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'local_database.dart';

class AppSettingsStore {
  static const _themeModeKey = 'theme_mode';
  static const _themeSeedKey = 'theme_seed';

  Future<Database> get _db => LocalDatabase.instance.database;

  Future<AppThemeSettings> loadThemeSettings() async {
    final db = await _db;
    final rows = await db.query('local_app_settings');
    final values = <String, String>{
      for (final row in rows) row['key'] as String: row['value'] as String,
    };
    return AppThemeSettings(
      mode: _parseThemeMode(values[_themeModeKey]),
      seedColorValue: int.tryParse(values[_themeSeedKey] ?? '') ??
          const Color(0xFF0B6E4F).toARGB32(),
    );
  }

  Future<void> saveThemeSettings(AppThemeSettings settings) async {
    final db = await _db;
    final batch = db.batch();
    batch.insert(
      'local_app_settings',
      {'key': _themeModeKey, 'value': settings.mode.name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    batch.insert(
      'local_app_settings',
      {'key': _themeSeedKey, 'value': settings.seedColorValue.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await batch.commit(noResult: true);
  }

  ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class AppThemeSettings {
  const AppThemeSettings({
    required this.mode,
    required this.seedColorValue,
  });

  final ThemeMode mode;
  final int seedColorValue;
}
