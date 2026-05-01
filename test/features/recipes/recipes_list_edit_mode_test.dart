import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/recipes/recipes_list_screen.dart';
import 'package:omnom/providers/recipe_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
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

    // No trash buttons in normal mode.
    expect(find.bySemanticsLabel(RegExp(r'^Delete .')), findsNothing);

    // Tap Edit.
    await tester.tap(find.bySemanticsLabel('Edit list'));
    await tester.pumpAndSettle();

    // Trash buttons now show — one per recipe.
    expect(
      find.bySemanticsLabel(RegExp(r'^Delete .')),
      findsNWidgets(before.length),
    );

    // Tap the first trash → confirm dialog → Delete.
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Delete .')).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete this recipe?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
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

    await tester.tap(find.bySemanticsLabel('Edit list'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Delete .')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    final after = c.read(recipesProvider).requireValue;
    expect(after.length, before.length);
  });
}
