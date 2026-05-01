import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/data/seed_data.dart';
import 'package:omnom/models/diary_entry.dart';
import 'package:omnom/models/recipe.dart';
import 'package:omnom/providers/repositories.dart';

Future<FakeFirebaseFirestore> seededFirestore({
  bool diary = true,
  bool recipes = true,
}) async {
  final fake = FakeFirebaseFirestore();
  if (diary) await seedDiary(fake, seedDiaryEntries);
  if (recipes) await seedRecipesInto(fake, seedRecipes);
  return fake;
}

FakeFirebaseFirestore emptyFirestore() => FakeFirebaseFirestore();

Future<void> seedDiary(FirebaseFirestore db, List<DiaryEntry> entries) async {
  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    final pos = (entries.length - i) * 1000;
    await db.collection('diary').doc(e.id).set({
      ...e.toJson(),
      'position': pos,
    });
  }
}

Future<void> seedRecipesInto(
    FirebaseFirestore db, List<Recipe> recipes) async {
  for (var i = 0; i < recipes.length; i++) {
    final r = recipes[i];
    final pos = (recipes.length - i) * 1000;
    await db.collection('recipes').doc(r.id).set({
      ...r.toJson(),
      'position': pos,
    });
  }
}

ProviderContainer makeContainer(FirebaseFirestore firestore,
    {List<Override> extraOverrides = const []}) {
  return ProviderContainer(overrides: [
    firestoreProvider.overrideWithValue(firestore),
    ...extraOverrides,
  ]);
}

/// Lets pending Firestore snapshot listeners flush so notifier state catches
/// up after writes. Run after every mutation in non-widget tests.
Future<void> settleStream() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
