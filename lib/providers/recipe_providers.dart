import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/recipe.dart';
import 'repositories.dart';

part 'recipe_providers.g.dart';

@Riverpod(keepAlive: true)
class Recipes extends _$Recipes {
  @override
  Future<List<Recipe>> build() async =>
      ref.read(recipeRepositoryProvider).load();
}
