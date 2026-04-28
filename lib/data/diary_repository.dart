import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';
import 'seed_data.dart';

class DiaryRepository {
  DiaryRepository(this._prefs);

  static const String storageKey = 'omnom_diary_v2';

  final SharedPreferences _prefs;

  Future<List<DiaryEntry>> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) {
      await save(seedDiaryEntries);
      return seedDiaryEntries;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return seedDiaryEntries;
    }
  }

  Future<void> save(List<DiaryEntry> entries) async {
    final encoded =
        jsonEncode(entries.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(storageKey, encoded);
  }
}
