import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/diary_repository.dart';
import '../data/recipe_repository.dart';
import '../data/settings_repository.dart';

part 'repositories.g.dart';

/// Overridden in main.dart with the awaited SharedPreferences instance.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
}

@Riverpod(keepAlive: true)
DiaryRepository diaryRepository(DiaryRepositoryRef ref) =>
    DiaryRepository(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(RecipeRepositoryRef ref) =>
    RecipeRepository(ref.watch(sharedPreferencesProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) =>
    SettingsRepository(ref.watch(sharedPreferencesProvider));
