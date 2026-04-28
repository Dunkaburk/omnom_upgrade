import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/data/diary_repository.dart';
import 'package:omnom/data/seed_data.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns seed entries when storage is empty', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = DiaryRepository(prefs);

    final loaded = await repo.load();

    expect(loaded.length, seedDiaryEntries.length);
    expect(loaded.first.id, seedDiaryEntries.first.id);
    // The seed should also be persisted on first load.
    expect(prefs.getString(DiaryRepository.storageKey), isNotNull);
  });

  test('save then load round-trips preserving order and fields', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = DiaryRepository(prefs);

    const next = [
      DiaryEntry(
        id: 'n1',
        title: 'Beef Stew',
        date: '2026-04-25',
        meal: 'Dinner',
        tags: ['beef', 'comfort'],
        r1: 7,
        r2: 8,
        activeTime: 30,
        passiveTime: 90,
        price: 9.50,
        country: 'France',
      ),
    ];
    await repo.save(next);
    final loaded = await repo.load();

    expect(loaded, next);
  });

  test('falls back to seed on corrupt JSON', () async {
    SharedPreferences.setMockInitialValues({
      DiaryRepository.storageKey: 'not-json',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = DiaryRepository(prefs);

    final loaded = await repo.load();
    expect(loaded.length, seedDiaryEntries.length);
  });
}
