import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/diary/diary_form_screen.dart';
import 'package:omnom/providers/diary_providers.dart';

import '../../_helpers/test_firestore.dart';

Future<Widget> _pump(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final fake = await seededFirestore();
  final container = makeContainer(fake);
  await container.read(diaryEntriesProvider.future);

  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: DiaryFormScreen()),
  );
}

InkWell _findSaveInkWell(WidgetTester tester) {
  final saveText = find.text('Spara inlägg');
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

    final titleField = find.widgetWithText(TextField, 'Vad lagade du?');
    expect(titleField, findsOneWidget);

    await tester.enterText(titleField, 'Pasta carbonara');
    await tester.pump();

    expect(_findSaveInkWell(tester).onTap, isNotNull);

    await tester.enterText(titleField, '   ');
    await tester.pump();
    expect(_findSaveInkWell(tester).onTap, isNull);
  });
}
