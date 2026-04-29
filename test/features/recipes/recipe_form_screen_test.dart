import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/recipes/recipe_form_screen.dart';
import 'package:omnom/providers/recipe_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _pump(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  await container.read(recipesProvider.future);

  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: RecipeFormScreen()),
  );
}

InkWell _findSaveInkWell(WidgetTester tester) {
  final saveText = find.text('Save recipe');
  expect(saveText, findsOneWidget);
  final inkWell = find.ancestor(
    of: saveText,
    matching: find.byType(InkWell),
  );
  expect(inkWell, findsOneWidget);
  return tester.widget<InkWell>(inkWell);
}

void main() {
  testWidgets('Save is disabled when title is empty', (tester) async {
    await tester.pumpWidget(await _pump(tester));
    await tester.pump();
    expect(_findSaveInkWell(tester).onTap, isNull);
  });

  testWidgets('Save enables once a title is typed', (tester) async {
    await tester.pumpWidget(await _pump(tester));
    await tester.pump();

    final titleField = find.widgetWithText(TextField, 'Recipe name');
    expect(titleField, findsOneWidget);

    await tester.enterText(titleField, 'Pancakes');
    await tester.pump();
    expect(_findSaveInkWell(tester).onTap, isNotNull);

    await tester.enterText(titleField, '   ');
    await tester.pump();
    expect(_findSaveInkWell(tester).onTap, isNull);
  });

  testWidgets('+ Add ingredient appends a blank ingredient row',
      (tester) async {
    await tester.pumpWidget(await _pump(tester));
    await tester.pump();

    // Initial: 1 ingredient row → 3 fields (qty, unit, name).
    final initialFields = find
        .widgetWithText(TextField, 'Ingredient')
        .evaluate()
        .length;
    expect(initialFields, 1);

    final addBtn = find.widgetWithText(InkWell, '+ Add');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pump();

    final afterFields = find
        .widgetWithText(TextField, 'Ingredient')
        .evaluate()
        .length;
    expect(afterFields, 2);
  });
}
