import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:omnom/models/recipe.dart';
import 'package:omnom/providers/diary_providers.dart';
import 'package:omnom/providers/recipe_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  await c.read(diaryEntriesProvider.future);
  await c.read(recipesProvider.future);
  return c;
}

void main() {
  group('DiaryEntries.remove', () {
    test('removes by id and persists', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final start = c.read(diaryEntriesProvider).requireValue;
      expect(start.any((e) => e.id == 's1'), isTrue);

      await c.read(diaryEntriesProvider.notifier).remove('s1');
      final after = c.read(diaryEntriesProvider).requireValue;
      expect(after.any((e) => e.id == 's1'), isFalse);
      expect(after.length, start.length - 1);

      // Reload from prefs to confirm persistence.
      final repo = c.read(diaryRepositoryProvider);
      final reloaded = await repo.load();
      expect(reloaded.any((e) => e.id == 's1'), isFalse);
    });

    test('remove() of unknown id is a no-op', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final start = c.read(diaryEntriesProvider).requireValue;
      await c.read(diaryEntriesProvider.notifier).remove('does-not-exist');
      final after = c.read(diaryEntriesProvider).requireValue;
      expect(after.length, start.length);
    });
  });

  group('DiaryEntries.move', () {
    test('moves an item from index 0 to index 2', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final ids =
          c.read(diaryEntriesProvider).requireValue.map((e) => e.id).toList();
      expect(ids.length, greaterThanOrEqualTo(3));

      // Move item at 0 down to index 2.
      await c.read(diaryEntriesProvider.notifier).move(0, 2);
      final after =
          c.read(diaryEntriesProvider).requireValue.map((e) => e.id).toList();

      // Original element previously at index 0 should now be at index 1
      // (ReorderableListView semantics: newIndex of 2 with item from 0
      //  resolves to insertion at 1 after removal).
      expect(after[1], ids[0]);
    });

    test('move persists through repository', () async {
      final c = await _container();
      addTearDown(c.dispose);

      await c.read(diaryEntriesProvider.notifier).move(0, 3);
      final inMem =
          c.read(diaryEntriesProvider).requireValue.map((e) => e.id).toList();
      final reloaded = (await c.read(diaryRepositoryProvider).load())
          .map((e) => e.id)
          .toList();
      expect(reloaded, inMem);
    });

    test('move with out-of-range oldIndex is a no-op', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final before =
          c.read(diaryEntriesProvider).requireValue.map((e) => e.id).toList();
      await c.read(diaryEntriesProvider.notifier).move(99, 0);
      final after =
          c.read(diaryEntriesProvider).requireValue.map((e) => e.id).toList();
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
      final after =
          c.read(recipesProvider).requireValue.map((r) => r.id).toList();
      // Previous item 0 should now be at index 1 (last).
      expect(after.last, ids[0]);
    });
  });

  group('list-card-actions integration types', () {
    test('DiaryEntry / Recipe values are stable after move', () async {
      final c = await _container();
      addTearDown(c.dispose);

      final entry = c.read(diaryEntriesProvider).requireValue.first;
      await c.read(diaryEntriesProvider.notifier).move(0, 1);
      final moved = c
          .read(diaryEntriesProvider)
          .requireValue
          .firstWhere((e) => e.id == entry.id);
      expect(moved, isA<DiaryEntry>());
      expect(moved.title, entry.title);

      final recipe = c.read(recipesProvider).requireValue.first;
      await c.read(recipesProvider.notifier).move(0, 1);
      final movedR = c
          .read(recipesProvider)
          .requireValue
          .firstWhere((r) => r.id == recipe.id);
      expect(movedR, isA<Recipe>());
      expect(movedR.title, recipe.title);
    });
  });
}
