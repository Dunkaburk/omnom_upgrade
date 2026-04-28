import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import 'seed_data.dart';

class RecipeRepository {
  RecipeRepository(this._prefs);

  static const String storageKey = 'omnom_recipes_v1';

  final SharedPreferences _prefs;

  Future<List<Recipe>> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) {
      await save(seedRecipes);
      return seedRecipes;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return seedRecipes;
    }
  }

  Future<void> save(List<Recipe> recipes) async {
    final encoded =
        jsonEncode(recipes.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(storageKey, encoded);
  }
}
