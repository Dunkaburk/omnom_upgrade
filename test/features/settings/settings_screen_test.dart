import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/features/settings/settings_screen.dart';
import 'package:omnom/providers/settings_providers.dart';

import '../../_helpers/test_firestore.dart';

Future<ProviderContainer> _container() async {
  final fake = emptyFirestore();
  final c = makeContainer(fake);
  await c.read(settingsControllerProvider.future);
  return c;
}

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('seeds inputs from current settings', (tester) async {
    final c = await _container();
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(find.widgetWithText(TextField, 'Person 1'), findsOneWidget);
    expect(find.text('Jonathan'), findsOneWidget);
    expect(find.text('Louise'), findsOneWidget);
  });

  testWidgets('saving persists trimmed names and selected accent',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);
    await _pump(tester, c);

    final p1Field = find.widgetWithText(TextField, 'Person 1');
    final p2Field = find.widgetWithText(TextField, 'Person 2');
    await tester.enterText(p1Field, '  Alex  ');
    await tester.enterText(p2Field, 'Sam');
    await tester.pump();

    final swatch = find.bySemanticsLabel('Accent #A0522D');
    expect(swatch, findsOneWidget);
    await tester.tap(swatch);
    await tester.pump();

    await tester.tap(find.text('Spara ändringar'));
    await tester.pumpAndSettle();

    final saved = c.read(settingsControllerProvider).requireValue;
    expect(saved.person1, 'Alex');
    expect(saved.person2, 'Sam');
    expect(saved.accentHex, '#A0522D');
  });

  testWidgets('empty name fallbacks to default Jonathan/Louise',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);
    await _pump(tester, c);

    await tester.enterText(find.widgetWithText(TextField, 'Person 1'), '   ');
    await tester.enterText(find.widgetWithText(TextField, 'Person 2'), '');
    await tester.pump();

    await tester.tap(find.text('Spara ändringar'));
    await tester.pumpAndSettle();

    final saved = c.read(settingsControllerProvider).requireValue;
    expect(saved.person1, 'Jonathan');
    expect(saved.person2, 'Louise');
  });

  testWidgets('typed hex updates accent and is persisted on save',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);
    await _pump(tester, c);

    final hexField = find.byKey(const Key('settings.hex-field'));
    expect(hexField, findsOneWidget);
    await tester.enterText(hexField, '#3F5772');
    await tester.pump();

    await tester.tap(find.text('Spara ändringar'));
    await tester.pumpAndSettle();

    final saved = c.read(settingsControllerProvider).requireValue;
    expect(saved.accentHex, '#3F5772');
  });

  testWidgets('invalid hex shows hint and does not overwrite previous accent',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);
    await _pump(tester, c);

    final hexField = find.byKey(const Key('settings.hex-field'));
    await tester.enterText(hexField, '#ZZZ');
    await tester.pump();

    expect(find.textContaining('Hexkod måste vara 6 tecken'), findsOneWidget);

    await tester.tap(find.text('Spara ändringar'));
    await tester.pumpAndSettle();

    final saved = c.read(settingsControllerProvider).requireValue;
    expect(saved.accentHex, '#C07B39');
  });
}
