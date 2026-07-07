import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_settings_store.dart';

enum AppIconVariant {
  defaultIcon('default', 'Default'),
  dark('dark', 'Dark'),
  neon('neon', 'Neon');

  const AppIconVariant(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static AppIconVariant fromStorage(String? value) {
    return AppIconVariant.values.firstWhere(
      (variant) => variant.storageValue == value,
      orElse: () => AppIconVariant.defaultIcon,
    );
  }
}

class AppIconController extends ChangeNotifier {
  AppIconController(this._store);

  static const _channel = MethodChannel('laras/app_icon');

  final AppSettingsStore _store;

  AppIconVariant _currentVariant = AppIconVariant.defaultIcon;

  AppIconVariant get currentVariant => _currentVariant;

  Future<void> load() async {
    final raw = await _store.loadLauncherIconVariant();
    _currentVariant = AppIconVariant.fromStorage(raw);
    notifyListeners();
  }

  Future<bool> setVariant(AppIconVariant variant) async {
    if (_currentVariant == variant) return true;

    final changed = await _channel.invokeMethod<bool>(
      'setIcon',
      {'variant': variant.storageValue},
    );
    if (changed != true) return false;

    _currentVariant = variant;
    await _store.saveLauncherIconVariant(variant.storageValue);
    notifyListeners();
    return true;
  }
}
