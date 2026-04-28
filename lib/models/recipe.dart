import 'package:freezed_annotation/freezed_annotation.dart';

import 'ingredient.dart';
import 'recipe_step.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String title,
    @Default('') String description,
    @Default('') String servings,
    @Default('') String country,
    @Default(<String>[]) List<String> tags,
    @Default(<Ingredient>[]) List<Ingredient> ingredients,
    @Default(<RecipeStep>[]) List<RecipeStep> steps,
    int? activeTime,
    int? passiveTime,
    double? price,
    String? photo,
    @Default('manual') String source, // "manual" | "url"
    String? sourceUrl,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}
