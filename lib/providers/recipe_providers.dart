import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/recipe.dart';
import 'repositories.dart';

part 'recipe_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sort options
// ─────────────────────────────────────────────────────────────────────────────

class RecipeSortOption {
  final String key;
  final String label;
  final String group;
  const RecipeSortOption(this.key, this.label, this.group);
}

const List<RecipeSortOption> kRecipeSortOptions = [
  RecipeSortOption('recent', 'Nyligen tillagt', 'Ordning'),
  RecipeSortOption('title_asc', 'Titel (A–Ö)', 'Ordning'),
  RecipeSortOption('title_desc', 'Titel (Ö–A)', 'Ordning'),
  RecipeSortOption('active_asc', 'Snabbast (aktiv)', 'Tid'),
  RecipeSortOption('active_desc', 'Längst (aktiv)', 'Tid'),
  RecipeSortOption('total_asc', 'Snabbast (total)', 'Tid'),
  RecipeSortOption('total_desc', 'Längst (total)', 'Tid'),
  RecipeSortOption('price_asc', 'Billigast först', 'Pris'),
  RecipeSortOption('price_desc', 'Dyrast först', 'Pris'),
  RecipeSortOption('ing_desc', 'Flest ingredienser', 'Övrigt'),
  RecipeSortOption('ing_asc', 'Färst ingredienser', 'Övrigt'),
];

RecipeSortOption recipeSortByKey(String key) => kRecipeSortOptions.firstWhere(
      (o) => o.key == key,
      orElse: () => kRecipeSortOptions.first,
    );

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class Recipes extends _$Recipes {
  @override
  Future<List<Recipe>> build() async =>
      ref.read(recipeRepositoryProvider).load();

  Future<void> add(Recipe recipe) async {
    final next = [recipe, ...?state.valueOrNull];
    state = AsyncData(next);
    await ref.read(recipeRepositoryProvider).save(next);
  }

  Future<void> updateEntry(Recipe recipe) async {
    final current = state.valueOrNull ?? const [];
    final next = [
      for (final r in current) if (r.id == recipe.id) recipe else r,
    ];
    state = AsyncData(next);
    await ref.read(recipeRepositoryProvider).save(next);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? const [];
    final next = current.where((r) => r.id != id).toList();
    state = AsyncData(next);
    await ref.read(recipeRepositoryProvider).save(next);
  }

  Future<void> move(int oldIndex, int newIndex) async {
    final current = [...?state.valueOrNull];
    if (oldIndex < 0 || oldIndex >= current.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > current.length) target = current.length;
    final recipe = current.removeAt(oldIndex);
    current.insert(target, recipe);
    state = AsyncData(current);
    await ref.read(recipeRepositoryProvider).save(current);
  }
}

@riverpod
class RecipeSort extends _$RecipeSort {
  @override
  String build() => 'recent';
  void set(String key) => state = key;
}

class RecipeFilterState {
  final String country; // empty = no filter
  final List<String> tags;
  const RecipeFilterState({
    this.country = '',
    this.tags = const [],
  });

  RecipeFilterState copyWith({
    String? country,
    List<String>? tags,
  }) =>
      RecipeFilterState(
        country: country ?? this.country,
        tags: tags ?? this.tags,
      );

  int get count => (country.isEmpty ? 0 : 1) + tags.length;

  bool get isActive => count > 0;

  RecipeFilterState toggleTag(String tag) {
    if (tags.contains(tag)) {
      return copyWith(tags: tags.where((t) => t != tag).toList());
    }
    return copyWith(tags: [...tags, tag]);
  }
}

@riverpod
class RecipeFilter extends _$RecipeFilter {
  @override
  RecipeFilterState build() => const RecipeFilterState();

  void setCountry(String country) => state = state.copyWith(country: country);
  void toggleTag(String tag) => state = state.toggleTag(tag);
  void clear() => state = const RecipeFilterState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Derived
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
List<String> allRecipeTags(AllRecipeTagsRef ref) {
  final recipes = ref.watch(recipesProvider).valueOrNull ?? const [];
  final set = <String>{};
  for (final r in recipes) {
    set.addAll(r.tags);
  }
  final list = set.toList()..sort();
  return list;
}

@riverpod
List<String> allRecipeCountries(AllRecipeCountriesRef ref) {
  final recipes = ref.watch(recipesProvider).valueOrNull ?? const [];
  final set = <String>{};
  for (final r in recipes) {
    final c = r.country.trim();
    if (c.isNotEmpty) set.add(c);
  }
  final list = set.toList()..sort();
  return list;
}

@riverpod
List<Recipe> sortedRecipes(SortedRecipesRef ref) {
  final recipes = ref.watch(recipesProvider).valueOrNull ?? const [];
  final sortKey = ref.watch(recipeSortProvider);
  final filter = ref.watch(recipeFilterProvider);

  final filtered = recipes.where((r) {
    if (filter.country.isNotEmpty && r.country != filter.country) return false;
    if (filter.tags.isNotEmpty &&
        !filter.tags.every((t) => r.tags.contains(t))) {
      return false;
    }
    return true;
  }).toList();

  int byActive(Recipe a, Recipe b) =>
      (a.activeTime ?? -1).compareTo(b.activeTime ?? -1);
  int byTotal(Recipe a, Recipe b) =>
      ((a.activeTime ?? 0) + (a.passiveTime ?? 0))
          .compareTo((b.activeTime ?? 0) + (b.passiveTime ?? 0));
  int byPrice(Recipe a, Recipe b) =>
      (a.price ?? -1).compareTo(b.price ?? -1);
  int byIngredients(Recipe a, Recipe b) =>
      a.ingredients.length.compareTo(b.ingredients.length);
  int byTitle(Recipe a, Recipe b) =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase());

  final sorted = [...filtered];
  switch (sortKey) {
    case 'title_asc':
      sorted.sort(byTitle);
    case 'title_desc':
      sorted.sort((a, b) => byTitle(b, a));
    case 'active_asc':
      sorted.sort(byActive);
    case 'active_desc':
      sorted.sort((a, b) => byActive(b, a));
    case 'total_asc':
      sorted.sort(byTotal);
    case 'total_desc':
      sorted.sort((a, b) => byTotal(b, a));
    case 'price_asc':
      sorted.sort(byPrice);
    case 'price_desc':
      sorted.sort((a, b) => byPrice(b, a));
    case 'ing_desc':
      sorted.sort((a, b) => byIngredients(b, a));
    case 'ing_asc':
      sorted.sort(byIngredients);
    case 'recent':
    default:
      // No-op: preserve insertion order (newest is at the front already).
      break;
  }
  return sorted;
}
