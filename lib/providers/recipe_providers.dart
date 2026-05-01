import 'dart:async';

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
  StreamSubscription<List<Recipe>>? _sub;

  @override
  Future<List<Recipe>> build() async {
    final repo = ref.read(recipeRepositoryProvider);
    ref.onDispose(() => _sub?.cancel());
    final completer = Completer<List<Recipe>>();
    _sub = repo.watch().listen(
      (recipes) {
        if (!completer.isCompleted) {
          completer.complete(recipes);
        } else {
          state = AsyncData(recipes);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          state = AsyncError(error, stack);
        }
      },
    );
    return completer.future;
  }

  Future<void> add(Recipe recipe) async {
    final current = state.valueOrNull ?? const [];
    final maxPos = current.fold<int>(
      0,
      (m, r) => r.position > m ? r.position : m,
    );
    await ref
        .read(recipeRepositoryProvider)
        .upsert(recipe.copyWith(position: maxPos + 1000));
  }

  Future<void> updateEntry(Recipe recipe) async {
    await ref.read(recipeRepositoryProvider).upsert(recipe);
  }

  Future<void> remove(String id) async {
    await ref.read(recipeRepositoryProvider).delete(id);
  }

  Future<void> move(int oldIndex, int newIndex) async {
    final current = [...?state.valueOrNull];
    if (oldIndex < 0 || oldIndex >= current.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target >= current.length) target = current.length - 1;
    if (target == oldIndex) return;

    final moved = current.removeAt(oldIndex);
    final upper = target > 0 ? current[target - 1].position : null;
    final lower = target < current.length ? current[target].position : null;
    final int newPos;
    if (upper != null && lower != null) {
      newPos = (upper + lower) ~/ 2;
    } else if (upper != null) {
      newPos = upper - 1000;
    } else if (lower != null) {
      newPos = lower + 1000;
    } else {
      newPos = 1000;
    }
    await ref
        .read(recipeRepositoryProvider)
        .upsert(moved.copyWith(position: newPos));
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
