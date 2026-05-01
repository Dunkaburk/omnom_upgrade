import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/data/seed_data.dart';
import 'package:omnom/providers/diary_providers.dart';

import '../_helpers/test_firestore.dart';

void main() {
  group('sortedDiaryEntriesProvider', () {
    test('default = newest first', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's1'); // 2026-04-20
      expect(sorted.last.id, 's6'); // 2026-03-30
    });

    test('rating_desc puts highest avg first', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      c.read(diarySortProvider.notifier).set('rating_desc');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's3');
    });

    test('price_asc puts cheapest first', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      c.read(diarySortProvider.notifier).set('price_asc');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's4');
    });

    test('total_asc considers active+passive', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      c.read(diarySortProvider.notifier).set('total_asc');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.id, 's4');
    });

    test('title sort is alphabetical case-insensitive', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      c.read(diarySortProvider.notifier).set('title');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.first.title, 'Avocado Toast');
    });
  });

  group('diaryFilterProvider', () {
    test('meal filter narrows to matching entries', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      c.read(diaryFilterProvider.notifier).setMeal('Frukost');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.length, 2);
      expect(sorted.every((e) => e.meal == 'Frukost'), isTrue);
    });

    test('tag filter is AND across multiple tags', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      c.read(diaryFilterProvider.notifier)
        ..toggleTag('eggs')
        ..toggleTag('simple');
      final sorted = c.read(sortedDiaryEntriesProvider);
      expect(sorted.length, 1);
      expect(sorted.first.id, 's4');
    });

    test('clear() resets meal and tags', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      final notifier = c.read(diaryFilterProvider.notifier)
        ..setMeal('Middag')
        ..toggleTag('italian');
      expect(c.read(diaryFilterProvider).count, 2);

      notifier.clear();
      expect(c.read(diaryFilterProvider).count, 0);
      expect(c.read(sortedDiaryEntriesProvider).length,
          seedDiaryEntries.length);
    });
  });

  group('allTagsProvider', () {
    test('returns distinct sorted union of entry tags', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      final tags = c.read(allTagsProvider);
      expect(tags, equals(List.of(tags)..sort()));
      expect(tags.toSet().length, tags.length);
      expect(tags.contains('italian'), isTrue);
      expect(tags.contains('eggs'), isTrue);
    });
  });
}
