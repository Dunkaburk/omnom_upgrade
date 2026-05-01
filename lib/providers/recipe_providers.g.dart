// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allRecipeTagsHash() => r'098056de26498555a27098c3c0152208f9762753';

/// See also [allRecipeTags].
@ProviderFor(allRecipeTags)
final allRecipeTagsProvider = AutoDisposeProvider<List<String>>.internal(
  allRecipeTags,
  name: r'allRecipeTagsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allRecipeTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRecipeTagsRef = AutoDisposeProviderRef<List<String>>;
String _$allRecipeCountriesHash() =>
    r'9c6d1bde1d961130ba31a5f5070baa483f8a94aa';

/// See also [allRecipeCountries].
@ProviderFor(allRecipeCountries)
final allRecipeCountriesProvider = AutoDisposeProvider<List<String>>.internal(
  allRecipeCountries,
  name: r'allRecipeCountriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allRecipeCountriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRecipeCountriesRef = AutoDisposeProviderRef<List<String>>;
String _$sortedRecipesHash() => r'594ccfbc678622cabd4ea487c8271b481b01baef';

/// See also [sortedRecipes].
@ProviderFor(sortedRecipes)
final sortedRecipesProvider = AutoDisposeProvider<List<Recipe>>.internal(
  sortedRecipes,
  name: r'sortedRecipesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sortedRecipesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortedRecipesRef = AutoDisposeProviderRef<List<Recipe>>;
String _$recipesHash() => r'6705635f2aadbcf65fb38d44050a61e069992873';

/// See also [Recipes].
@ProviderFor(Recipes)
final recipesProvider = AsyncNotifierProvider<Recipes, List<Recipe>>.internal(
  Recipes.new,
  name: r'recipesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recipesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Recipes = AsyncNotifier<List<Recipe>>;
String _$recipeSortHash() => r'4cf4a9db45605f80078bced0429dfbc12666ffbb';

/// See also [RecipeSort].
@ProviderFor(RecipeSort)
final recipeSortProvider =
    AutoDisposeNotifierProvider<RecipeSort, String>.internal(
  RecipeSort.new,
  name: r'recipeSortProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recipeSortHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecipeSort = AutoDisposeNotifier<String>;
String _$recipeFilterHash() => r'e01262ec7a22d839e5a5391e6b6b6d1cb346b120';

/// See also [RecipeFilter].
@ProviderFor(RecipeFilter)
final recipeFilterProvider =
    AutoDisposeNotifierProvider<RecipeFilter, RecipeFilterState>.internal(
  RecipeFilter.new,
  name: r'recipeFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recipeFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecipeFilter = AutoDisposeNotifier<RecipeFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
