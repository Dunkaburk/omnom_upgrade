import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/diary/diary_form_screen.dart';
import 'package:omnom/providers/diary_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _pump(WidgetTester tester) async {
  // Avoid HTTP fetches for fonts during tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  // Pre-warm the diary provider so the repository is initialised by the time
  // the form mounts (saves use ref.read on the notifier).
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  await container.read(diaryEntriesProvider.future);

  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: DiaryFormScreen()),
  );
}

InkWell _findSaveInkWell(WidgetTester tester) {
  // The Save button is built as: Material > InkWell > Padding > Center > Text.
  // Walk up from the visible 'Save entry' Text to the InkWell ancestor.
  final saveText = find.text('Save entry');
  expect(saveText, findsOneWidget);
  final inkWell = find.ancestor(
    of: saveText,
    matching: find.byType(InkWell),
  );
  expect(inkWell, findsOneWidget);
  return tester.widget<InkWell>(inkWell);
}

void main() {
  testWidgets('Save button is disabled when title is empty', (tester) async {
    await tester.pumpWidget(await _pump(tester));
    await tester.pump();

    expect(_findSaveInkWell(tester).onTap, isNull);
  });

  testWidgets('Save button enables once a non-empty title is entered',
      (tester) async {
    await tester.pumpWidget(await _pump(tester));
    await tester.pump();

    // Find the title TextField — it's the first one (placeholder "What did you make?").
    final titleField = find.widgetWithText(TextField, 'What did you make?');
    expect(titleField, findsOneWidget);

    await tester.enterText(titleField, 'Pasta carbonara');
    await tester.pump();

    expect(_findSaveInkWell(tester).onTap, isNotNull);

    // Clearing the title disables the button again.
    await tester.enterText(titleField, '   ');
    await tester.pump();
    expect(_findSaveInkWell(tester).onTap, isNull);
  });
}
