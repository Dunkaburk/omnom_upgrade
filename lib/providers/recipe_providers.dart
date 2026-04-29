import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/recipe.dart';
import 'repositories.dart';

part 'recipe_providers.g.dart';

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
}
