import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/recipe.dart';
import 'package:omnom/providers/recipe_providers.dart';

import '../_helpers/test_firestore.dart';

void main() {
  group('Recipes notifier', () {
    test('add() inserts and persists through Firestore', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(recipesProvider.future);

      final initialCount = c.read(recipesProvider).valueOrNull?.length ?? 0;

      const r = Recipe(id: 'r-new', title: 'Pancakes');
      await c.read(recipesProvider.notifier).add(r);
      await settleStream();

      final after = c.read(recipesProvider).valueOrNull!;
      expect(after.length, initialCount + 1);
      expect(after.first.id, 'r-new');

      final c2 = makeContainer(fake);
      addTearDown(c2.dispose);
      await c2.read(recipesProvider.future);
      expect(
        c2.read(recipesProvider).valueOrNull!.any((x) => x.id == 'r-new'),
        isTrue,
      );
    });

    test('updateEntry() mutates by id and persists', () async {
      final fake = await seededFirestore();
      final c = makeContainer(fake);
      addTearDown(c.dispose);
      await c.read(recipesProvider.future);

      final original = c.read(recipesProvider).valueOrNull!.first;
      await c
          .read(recipesProvider.notifier)
          .updateEntry(original.copyWith(title: 'changed-title'));
      await settleStream();

      final after = c
          .read(recipesProvider)
          .valueOrNull!
          .firstWhere((r) => r.id == original.id);
      expect(after.title, 'changed-title');

      final c2 = makeContainer(fake);
      addTearDown(c2.dispose);
      await c2.read(recipesProvider.future);
      final reloaded = c2
          .read(recipesProvider)
          .valueOrNull!
          .firstWhere((r) => r.id == original.id);
      expect(reloaded.title, 'changed-title');
    });
  });
}
