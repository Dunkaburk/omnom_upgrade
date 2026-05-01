import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:omnom/providers/diary_providers.dart';

import '../_helpers/test_firestore.dart';

void main() {
  group('DiaryEntries notifier', () {
    test('add() inserts entry and persists through Firestore', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      final initialCount =
          c.read(diaryEntriesProvider).valueOrNull?.length ?? 0;

      const e = DiaryEntry(
        id: 'new1',
        title: 'New entry',
        date: '2026-04-28',
        meal: 'Lunch',
      );
      await c.read(diaryEntriesProvider.notifier).add(e);
      await settleStream();

      final after = c.read(diaryEntriesProvider).valueOrNull!;
      expect(after.length, initialCount + 1);
      expect(after.first.id, 'new1');

      // A fresh container reading the same Firestore sees the new entry.
      final c2 = makeContainer(fake);
      addTearDown(c2.dispose);
      await c2.read(diaryEntriesProvider.future);
      final reloaded = c2.read(diaryEntriesProvider).valueOrNull!;
      expect(reloaded.any((e) => e.id == 'new1'), isTrue);
    });

    test('updateEntry() mutates by id and persists', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(diaryEntriesProvider.future);

      final original = c.read(diaryEntriesProvider).valueOrNull!.first;
      final edited = original.copyWith(title: 'changed-title');
      await c.read(diaryEntriesProvider.notifier).updateEntry(edited);
      await settleStream();

      final after = c
          .read(diaryEntriesProvider)
          .valueOrNull!
          .firstWhere((e) => e.id == original.id);
      expect(after.title, 'changed-title');

      final c2 = makeContainer(fake);
      addTearDown(c2.dispose);
      await c2.read(diaryEntriesProvider.future);
      final reloaded = c2
          .read(diaryEntriesProvider)
          .valueOrNull!
          .firstWhere((e) => e.id == original.id);
      expect(reloaded.title, 'changed-title');
    });
  });
}
