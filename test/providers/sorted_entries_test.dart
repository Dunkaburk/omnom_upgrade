import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/data/seed_data.dart';
import 'package:omnom/providers/diary_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _makeContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  // Wait for initial load.
  await container.read(diaryEntriesProvider.future);
  return container;
}

void main() {
  group('sortedDiaryEntriesProvider', () {
    test('default = newest first', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's1'); // 2026-04-20
      expect(sorted.last.id, 's6');  // 2026-03-30
    });

    test('rating_desc puts highest avg first', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      c.read(diarySortProvider.notifier).set('rating_desc');
      final sorted = c.read(sortedDiaryEntriesProvider);
      // s3 (10/10 avg=10) should be first.
      expect(sorted.first.id, 's3');
    });

    test('price_asc puts cheapest first', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      c.read(diarySortProvider.notifier).set('price_asc');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's4'); // £4.50
    });

    test('total_asc considers active+passive', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      c.read(diarySortProvider.notifier).set('total_asc');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's4'); // 10+0 = 10 min
    });

    test('title sort is alphabetical case-insensitive', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      c.read(diarySortProvider.notifier).set('title');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.title, 'Avocado Toast');
    });
  });

  group('diaryFilterProvider', () {
    test('meal filter narrows to matching entries', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      c.read(diaryFilterProvider.notifier).setMeal('Breakfast');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.length, 2); // s2, s4
      expect(sorted.every((e) => e.meal == 'Breakfast'), isTrue);
    });

    test('tag filter is AND across multiple tags', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      c.read(diaryFilterProvider.notifier)
        ..toggleTag('eggs')
        ..toggleTag('simple');
      final sorted = c.read(sortedDiaryEntriesProvider);
      // Only s4 has both 'eggs' AND 'simple'.
      expect(sorted.length, 1);
      expect(sorted.first.id, 's4');
    });

    test('clear() resets meal and tags', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      final notifier = c.read(diaryFilterProvider.notifier)
        ..setMeal('Dinner')
        ..toggleTag('italian');
      expect(c.read(diaryFilterProvider).count, 2);

      notifier.clear();
      expect(c.read(diaryFilterProvider).count, 0);
      expect(c.read(sortedDiaryEntriesProvider).length, seedDiaryEntries.length);
    });
  });

  group('allTagsProvider', () {
    test('returns distinct sorted union of entry tags', () async {
      final c = await _makeContainer();
      addTearDown(c.dispose);

      final tags = c.read(allTagsProvider);
      // No duplicates; sorted alphabetically.
      expect(tags, equals(List.of(tags)..sort()));
      expect(tags.toSet().length, tags.length);
      expect(tags.contains('italian'), isTrue);
      expect(tags.contains('eggs'), isTrue);
    });
  });
}
