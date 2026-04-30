import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/models/ingredient.dart';
import 'package:omnom/models/recipe.dart';
import 'package:omnom/providers/recipe_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _makeContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  await container.read(recipesProvider.future);
  return container;
}

Recipe _r({
  required String id,
  required String title,
  String country = '',
  List<String> tags = const [],
  String source = 'manual',
  int? active,
  int? passive,
  double? price,
  int ingredients = 0,
}) {
  return Recipe(
    id: id,
    title: title,
    country: country,
    tags: tags,
    source: source,
    activeTime: active,
    passiveTime: passive,
    price: price,
    ingredients: [
      for (var i = 0; i < ingredients; i++)
        Ingredient(id: '$id-i$i', name: 'ing$i'),
    ],
  );
}

Future<ProviderContainer> _seeded(List<Recipe> recipes) async {
  final c = await _makeContainer();
  // Replace with our deterministic test set.
  final notifier = c.read(recipesProvider.notifier);
  // Remove seed recipes first.
  final seedIds = (c.read(recipesProvider).valueOrNull ?? const [])
      .map((r) => r.id)
      .toList();
  for (final id in seedIds) {
    await notifier.remove(id);
  }
  for (final r in recipes.reversed) {
    await notifier.add(r);
  }
  return c;
}

void main() {
  group('sortedRecipesProvider', () {
    test('default = recently-added (insertion order preserved)', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'Alpha'),
        _r(id: 'b', title: 'Beta'),
        _r(id: 'c', title: 'Gamma'),
      ]);
      addTearDown(c.dispose);

      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.map((r) => r.id), ['a', 'b', 'c']);
    });

    test('title_asc sorts case-insensitively', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'banana'),
        _r(id: 'b', title: 'Apple'),
        _r(id: 'c', title: 'cherry'),
      ]);
      addTearDown(c.dispose);

      c.read(recipeSortProvider.notifier).set('title_asc');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.map((r) => r.title), ['Apple', 'banana', 'cherry']);
    });

    test('total_asc considers active+passive', () async {
      final c = await _seeded([
        _r(id: 'long', title: 'Long', active: 30, passive: 60),
        _r(id: 'short', title: 'Short', active: 5),
        _r(id: 'mid', title: 'Mid', active: 20, passive: 0),
      ]);
      addTearDown(c.dispose);

      c.read(recipeSortProvider.notifier).set('total_asc');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.map((r) => r.id), ['short', 'mid', 'long']);
    });

    test('ing_desc puts most-ingredient recipes first', () async {
      final c = await _seeded([
        _r(id: 'few', title: 'Few', ingredients: 2),
        _r(id: 'many', title: 'Many', ingredients: 10),
        _r(id: 'mid', title: 'Mid', ingredients: 5),
      ]);
      addTearDown(c.dispose);

      c.read(recipeSortProvider.notifier).set('ing_desc');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.first.id, 'many');
      expect(sorted.last.id, 'few');
    });
  });

  group('recipeFilterProvider', () {
    test('country filter narrows to matching recipes', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', country: 'Italy'),
        _r(id: 'b', title: 'B', country: 'Japan'),
        _r(id: 'c', title: 'C', country: 'Italy'),
      ]);
      addTearDown(c.dispose);

      c.read(recipeFilterProvider.notifier).setCountry('Italy');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.length, 2);
      expect(sorted.every((r) => r.country == 'Italy'), isTrue);
    });

    test('tag filter is AND across multiple tags', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', tags: ['quick', 'pasta']),
        _r(id: 'b', title: 'B', tags: ['pasta']),
        _r(id: 'c', title: 'C', tags: ['quick', 'soup']),
      ]);
      addTearDown(c.dispose);

      c.read(recipeFilterProvider.notifier)
        ..toggleTag('quick')
        ..toggleTag('pasta');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.length, 1);
      expect(sorted.first.id, 'a');
    });

    test('source filter narrows to selected sources', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', source: 'manual'),
        _r(id: 'b', title: 'B', source: 'url'),
        _r(id: 'c', title: 'C', source: 'manual'),
      ]);
      addTearDown(c.dispose);

      c.read(recipeFilterProvider.notifier).toggleSource('url');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.map((r) => r.id), ['b']);
    });

    test('multi-select sources is OR', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', source: 'manual'),
        _r(id: 'b', title: 'B', source: 'url'),
      ]);
      addTearDown(c.dispose);

      c.read(recipeFilterProvider.notifier)
        ..toggleSource('manual')
        ..toggleSource('url');
      final sorted = c.read(sortedRecipesProvider);
      expect(sorted.length, 2);
    });

    test('clear() resets country, tags, sources', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', country: 'Italy', tags: ['quick']),
      ]);
      addTearDown(c.dispose);

      final notifier = c.read(recipeFilterProvider.notifier)
        ..setCountry('Italy')
        ..toggleTag('quick')
        ..toggleSource('url');
      expect(c.read(recipeFilterProvider).count, 3);

      notifier.clear();
      expect(c.read(recipeFilterProvider).count, 0);
    });
  });

  group('allRecipeTagsProvider / allRecipeCountriesProvider', () {
    test('tags returns deduped sorted union', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', tags: ['quick', 'pasta']),
        _r(id: 'b', title: 'B', tags: ['pasta', 'soup']),
      ]);
      addTearDown(c.dispose);

      final tags = c.read(allRecipeTagsProvider);
      expect(tags, ['pasta', 'quick', 'soup']);
    });

    test('countries skips empties and trims', () async {
      final c = await _seeded([
        _r(id: 'a', title: 'A', country: 'Italy'),
        _r(id: 'b', title: 'B', country: ''),
        _r(id: 'c', title: 'C', country: '  Japan  '),
      ]);
      addTearDown(c.dispose);

      final countries = c.read(allRecipeCountriesProvider);
      // 'Italy' and 'Japan' (note: trimmed); '  Japan  ' as stored value, but
      // allRecipeCountriesProvider trims before adding to the set.
      expect(countries, ['Italy', 'Japan']);
    });
  });
}
