import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'local_database.dart';
import 'theme_controller.dart';

class AppSettingsStore {
  static const _themeModeKey = 'theme_mode';
  static const _themeSeedKey = 'theme_seed';
  static const _launcherIconKey = 'launcher_icon';
  static const _localeCodeKey = 'locale_code';

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
          ThemeController.defaultSeedColor.toARGB32(),
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

  Future<String?> loadLauncherIconVariant() async {
    final db = await _db;
    final rows = await db.query(
      'local_app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_launcherIconKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> saveLauncherIconVariant(String variant) async {
    final db = await _db;
    await db.insert(
      'local_app_settings',
      {'key': _launcherIconKey, 'value': variant},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> loadLocaleCode() async {
    final db = await _db;
    final rows = await db.query(
      'local_app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_localeCodeKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> saveLocaleCode(String code) async {
    final db = await _db;
    await db.insert(
      'local_app_settings',
      {'key': _localeCodeKey, 'value': code},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
