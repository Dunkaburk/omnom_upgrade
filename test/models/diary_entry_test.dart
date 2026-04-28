import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:omnom/data/seed_data.dart';

void main() {
  test('DiaryEntry round-trips through JSON preserving all fields', () {
    for (final entry in seedDiaryEntries) {
      final round = DiaryEntry.fromJson(entry.toJson());
      expect(round, entry);
    }
  });

  test('DiaryEntry handles all-null optional fields', () {
    const entry = DiaryEntry(
      id: 'x1',
      title: 'Bare',
      date: '2026-01-01',
      meal: 'Other',
    );
    final round = DiaryEntry.fromJson(entry.toJson());
    expect(round, entry);
    expect(round.r1, isNull);
    expect(round.activeTime, isNull);
    expect(round.price, isNull);
    expect(round.country, isNull);
    expect(round.tags, isEmpty);
    expect(round.desc, '');
  });
}
