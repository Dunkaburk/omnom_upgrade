import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/diary_entry.dart';

class DiaryRepository {
  DiaryRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('diary');

  Stream<List<DiaryEntry>> watch() {
    return _col.orderBy('position', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => DiaryEntry.fromJson(d.data()))
              .toList(growable: false),
        );
  }

  Future<void> upsert(DiaryEntry entry) async {
    await _col.doc(entry.id).set(entry.toJson());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
