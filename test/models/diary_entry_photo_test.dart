import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/diary_entry.dart';

void main() {
  test('DiaryEntry preserves a base64 photo data URL through JSON', () {
    final bytes = List<int>.generate(2048, (i) => i % 256);
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    final entry = DiaryEntry(
      id: 'photo1',
      title: 'With photo',
      date: '2026-04-28',
      meal: 'Dinner',
      photo: dataUrl,
    );

    final round = DiaryEntry.fromJson(entry.toJson());
    expect(round.photo, dataUrl);
    expect(round, entry);
  });
}
