import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/recipes/recipe_form_screen.dart';
import 'package:omnom/providers/recipe_providers.dart';

import '../../_helpers/test_firestore.dart';

Future<Widget> _pump(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final fake = await seededFirestore();
  final container = makeContainer(fake);
  await container.read(recipesProvider.future);

  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: RecipeFormScreen()),
  );
}

InkWell _findSaveInkWell(WidgetTester tester) {
  final saveText = find.text('Spara recept');
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

    final titleField = find.widgetWithText(TextField, 'Receptnamn');
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

    final initialFields = find
        .widgetWithText(TextField, 'Ingrediens')
        .evaluate()
        .length;
    expect(initialFields, 1);

    final addBtn = find.widgetWithText(InkWell, '+ Lägg till');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pump();

    final afterFields = find
        .widgetWithText(TextField, 'Ingrediens')
        .evaluate()
        .length;
    expect(afterFields, 2);
  });
}
