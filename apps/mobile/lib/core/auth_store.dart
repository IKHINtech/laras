import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  static const _tokenKey = 'laras.token';
  static const _offlineEntryKey = 'laras.offline_entry_seen';
  String? token;
  bool hasSeenOfflineHome = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    hasSeenOfflineHome = prefs.getBool(_offlineEntryKey) ?? false;
  }

  Future<void> saveToken(String value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, value);
  }

  Future<void> clear() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> markOfflineHomeSeen() async {
    hasSeenOfflineHome = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineEntryKey, true);
  }
}
