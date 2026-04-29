import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/data/countries.dart';
import 'package:omnom/features/other/discover_screen.dart';
import 'package:omnom/providers/discover_providers.dart';
import 'package:omnom/providers/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container({Set<String>? cooked}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    if (cooked != null) cookedCountriesProvider.overrideWithValue(cooked),
  ]);
}

InkWell _randomizeInkWell(WidgetTester tester, {required bool spinning}) {
  final label = spinning ? 'Picking…' : '🎲 Randomize a country';
  final btnText = find.text(label);
  expect(btnText, findsOneWidget);
  final inkWell = find.ancestor(of: btnText, matching: find.byType(InkWell));
  return tester.widget<InkWell>(inkWell.first);
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Randomize button is enabled when the pool has countries',
      (tester) async {
    final c = await _container();
    addTearDown(c.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ),
    );
    await tester.pump();

    expect(_randomizeInkWell(tester, spinning: false).onTap, isNotNull);
  });

  testWidgets('Randomize button disables when the pool is empty',
      (tester) async {
    // Mark every country as already cooked, then turn on Undiscovered Only.
    final allCooked = {for (final c in kCountries) c.name};
    final c = await _container(cooked: allCooked);
    addTearDown(c.dispose);

    c.read(discoverControllerProvider.notifier).setUndiscoveredOnly(true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ),
    );
    await tester.pump();

    expect(c.read(discoverPoolProvider), isEmpty);
    expect(find.text('No countries match your filters.'), findsOneWidget);
    expect(_randomizeInkWell(tester, spinning: false).onTap, isNull);
  });
}
