import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';

class RecipeRepository {
  RecipeRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('recipes');

  Stream<List<Recipe>> watch() {
    return _col.orderBy('position', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => Recipe.fromJson(d.data()))
              .toList(growable: false),
        );
  }

  Future<void> upsert(Recipe recipe) async {
    await _col.doc(recipe.id).set(recipe.toJson());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
