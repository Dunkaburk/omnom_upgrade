import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  static const String storageKey = 'omnom_settings_v1';

  final SharedPreferences _prefs;

  Future<Settings> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return const Settings();
    try {
      return Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Settings();
    }
  }

  Future<void> save(Settings settings) async {
    await _prefs.setString(storageKey, jsonEncode(settings.toJson()));
  }
}
