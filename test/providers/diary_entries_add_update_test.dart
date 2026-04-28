import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:omnom/providers/diary_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _makeContainer(SharedPreferences prefs) async {
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  await container.read(diaryEntriesProvider.future);
  return container;
}

void main() {
  group('DiaryEntries notifier', () {
    test('add() prepends entry and persists through repository', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = await _makeContainer(prefs);
      addTearDown(c.dispose);

      final initialCount =
          c.read(diaryEntriesProvider).valueOrNull?.length ?? 0;

      const e = DiaryEntry(
        id: 'new1',
        title: 'New entry',
        date: '2026-04-28',
        meal: 'Lunch',
      );
      await c.read(diaryEntriesProvider.notifier).add(e);

      final after = c.read(diaryEntriesProvider).valueOrNull!;
      expect(after.length, initialCount + 1);
      expect(after.first.id, 'new1');

      // Persisted: a fresh container reading the same SharedPreferences
      // sees the new entry.
      final c2 = await _makeContainer(prefs);
      addTearDown(c2.dispose);
      final reloaded = c2.read(diaryEntriesProvider).valueOrNull!;
      expect(reloaded.any((e) => e.id == 'new1'), isTrue);
    });

    test('updateEntry() mutates by id and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = await _makeContainer(prefs);
      addTearDown(c.dispose);

      final original = c.read(diaryEntriesProvider).valueOrNull!.first;
      final edited = original.copyWith(title: 'changed-title');
      await c.read(diaryEntriesProvider.notifier).updateEntry(edited);

      final after = c
          .read(diaryEntriesProvider)
          .valueOrNull!
          .firstWhere((e) => e.id == original.id);
      expect(after.title, 'changed-title');

      final c2 = await _makeContainer(prefs);
      addTearDown(c2.dispose);
      final reloaded = c2
          .read(diaryEntriesProvider)
          .valueOrNull!
          .firstWhere((e) => e.id == original.id);
      expect(reloaded.title, 'changed-title');
    });
  });
}
