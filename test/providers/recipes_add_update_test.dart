import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/recipe.dart';
import 'package:omnom/providers/recipe_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _makeContainer(SharedPreferences prefs) async {
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  await container.read(recipesProvider.future);
  return container;
}

void main() {
  group('Recipes notifier', () {
    test('add() prepends and persists through repository', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = await _makeContainer(prefs);
      addTearDown(c.dispose);

      final initialCount = c.read(recipesProvider).valueOrNull?.length ?? 0;

      const r = Recipe(id: 'r-new', title: 'Pancakes');
      await c.read(recipesProvider.notifier).add(r);

      final after = c.read(recipesProvider).valueOrNull!;
      expect(after.length, initialCount + 1);
      expect(after.first.id, 'r-new');

      final c2 = await _makeContainer(prefs);
      addTearDown(c2.dispose);
      expect(
        c2.read(recipesProvider).valueOrNull!.any((x) => x.id == 'r-new'),
        isTrue,
      );
    });

    test('updateEntry() mutates by id and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = await _makeContainer(prefs);
      addTearDown(c.dispose);

      final original = c.read(recipesProvider).valueOrNull!.first;
      await c
          .read(recipesProvider.notifier)
          .updateEntry(original.copyWith(title: 'changed-title'));

      final after = c
          .read(recipesProvider)
          .valueOrNull!
          .firstWhere((r) => r.id == original.id);
      expect(after.title, 'changed-title');

      final c2 = await _makeContainer(prefs);
      addTearDown(c2.dispose);
      final reloaded = c2
          .read(recipesProvider)
          .valueOrNull!
          .firstWhere((r) => r.id == original.id);
      expect(reloaded.title, 'changed-title');
    });
  });
}
