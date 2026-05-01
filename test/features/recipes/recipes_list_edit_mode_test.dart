import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/recipes/recipes_list_screen.dart';
import 'package:omnom/providers/recipe_providers.dart';

import '../../_helpers/test_firestore.dart';

Future<ProviderContainer> _container() async {
  final fake = await seededFirestore();
  final c = makeContainer(fake);
  await c.read(recipesProvider.future);
  return c;
}

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: RecipesListScreen()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Edit toggle reveals trash icons; tapping deletes after confirm',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);

    await _pump(tester, c);
    final before = c.read(recipesProvider).requireValue;
    expect(before, isNotEmpty);

    expect(find.bySemanticsLabel(RegExp(r'^Ta bort .')), findsNothing);

    await tester.tap(find.bySemanticsLabel('Redigera lista'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp(r'^Ta bort .')),
      findsNWidgets(before.length),
    );

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Ta bort .')).first);
    await tester.pumpAndSettle();
    expect(find.text('Ta bort receptet?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Ta bort'));
    await tester.pumpAndSettle();

    final after = c.read(recipesProvider).requireValue;
    expect(after.length, before.length - 1);
  });

  testWidgets('Cancelling the confirm dialog leaves the recipe in place',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);

    await _pump(tester, c);
    final before = c.read(recipesProvider).requireValue;

    await tester.tap(find.bySemanticsLabel('Redigera lista'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Ta bort .')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Avbryt'));
    await tester.pumpAndSettle();

    final after = c.read(recipesProvider).requireValue;
    expect(after.length, before.length);
  });
}
