import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;

import '../models/settings.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('settings').doc('main');

  Stream<Settings> watch() {
    return _doc.snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return const Settings();
      try {
        return Settings.fromJson(data);
      } catch (_) {
        return const Settings();
      }
    });
  }

  Future<void> save(Settings settings) async {
    await _doc.set(settings.toJson());
  }
}
