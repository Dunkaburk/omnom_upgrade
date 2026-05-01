import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:omnom/models/recipe.dart';
import 'package:omnom/providers/diary_providers.dart';
import 'package:omnom/providers/recipe_providers.dart';

import '../_helpers/test_firestore.dart';

Future<ProviderContainer> _container() async {
  final fake = await seededFirestore();
  final c = makeContainer(fake);
  await c.read(diaryEntriesProvider.future);
  await c.read(recipesProvider.future);
  return c;
}

void main() {
  group('DiaryEntries.remove', () {
    test('removes by id', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final start = c.read(diaryEntriesProvider).requireValue;
      expect(start.any((e) => e.id == 's1'), isTrue);

      await c.read(diaryEntriesProvider.notifier).remove('s1');
      await settleStream();

      final after = c.read(diaryEntriesProvider).requireValue;
      expect(after.any((e) => e.id == 's1'), isFalse);
      expect(after.length, start.length - 1);
    });

    test('remove() of unknown id is a no-op', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final start = c.read(diaryEntriesProvider).requireValue;
      await c.read(diaryEntriesProvider.notifier).remove('does-not-exist');
      await settleStream();

      final after = c.read(diaryEntriesProvider).requireValue;
      expect(after.length, start.length);
    });
  });

  group('DiaryEntries.move', () {
    test('moves an item from index 0 to index 2', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final ids = c
          .read(diaryEntriesProvider)
          .requireValue
          .map((e) => e.id)
          .toList();
      expect(ids.length, greaterThanOrEqualTo(3));

      await c.read(diaryEntriesProvider.notifier).move(0, 2);
      await settleStream();

      final after = c
          .read(diaryEntriesProvider)
          .requireValue
          .map((e) => e.id)
          .toList();
      expect(after[1], ids[0]);
    });

    test('move with out-of-range oldIndex is a no-op', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final before = c
          .read(diaryEntriesProvider)
          .requireValue
          .map((e) => e.id)
          .toList();
      await c.read(diaryEntriesProvider.notifier).move(99, 0);
      await settleStream();

      final after = c
          .read(diaryEntriesProvider)
          .requireValue
          .map((e) => e.id)
          .toList();
      expect(after, before);
    });
  });

  group('Recipes.remove + move', () {
    test('remove pulls a recipe from the list', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final start = c.read(recipesProvider).requireValue;
      expect(start.length, greaterThanOrEqualTo(2));

      final firstId = start.first.id;
      await c.read(recipesProvider.notifier).remove(firstId);
      await settleStream();

      final after = c.read(recipesProvider).requireValue;
      expect(after.any((r) => r.id == firstId), isFalse);
    });

    test('move swaps recipe order', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final ids =
          c.read(recipesProvider).requireValue.map((r) => r.id).toList();
      if (ids.length < 2) return;

      await c.read(recipesProvider.notifier).move(0, 2);
      await settleStream();

      final after =
          c.read(recipesProvider).requireValue.map((r) => r.id).toList();
      expect(after.last, ids[0]);
    });
  });

  group('list-card-actions integration types', () {
    test('DiaryEntry / Recipe values are stable after move', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final entry = c.read(diaryEntriesProvider).requireValue.first;
      await c.read(diaryEntriesProvider.notifier).move(0, 1);
      await settleStream();
      final moved = c
          .read(diaryEntriesProvider)
          .requireValue
          .firstWhere((e) => e.id == entry.id);
      expect(moved, isA<DiaryEntry>());
      expect(moved.title, entry.title);

      final recipe = c.read(recipesProvider).requireValue.first;
      await c.read(recipesProvider.notifier).move(0, 1);
      await settleStream();
      final movedR = c
          .read(recipesProvider)
          .requireValue
          .firstWhere((r) => r.id == recipe.id);
      expect(movedR, isA<Recipe>());
      expect(movedR.title, recipe.title);
    });
  });
}
