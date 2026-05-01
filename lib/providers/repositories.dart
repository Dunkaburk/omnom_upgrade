import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/diary_repository.dart';
import '../data/recipe_repository.dart';
import '../data/settings_repository.dart';

part 'repositories.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(FirestoreRef ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
DiaryRepository diaryRepository(DiaryRepositoryRef ref) =>
    DiaryRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(RecipeRepositoryRef ref) =>
    RecipeRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) =>
    SettingsRepository(ref.watch(firestoreProvider));
