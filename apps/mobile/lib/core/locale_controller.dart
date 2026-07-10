import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'app_settings_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._store);

  final AppSettingsStore _store;

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> load() async {
    _locale = _parseLocale(await _store.loadLocaleCode());
    notifyListeners();
  }

  Future<void> setLocaleCode(String code) async {
    _locale = _parseLocale(code);
    await _store.saveLocaleCode(code);
    notifyListeners();
  }

  String get currentCode => _locale?.languageCode ?? 'system';

  Locale? _parseLocale(String? code) {
    switch (code) {
      case 'en':
        return const Locale('en');
      case 'id':
        return const Locale('id');
      case 'ja':
        return const Locale('ja');
      default:
        return null;
    }
  }
}
