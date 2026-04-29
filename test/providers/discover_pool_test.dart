import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/data/countries.dart';
import 'package:omnom/providers/discover_providers.dart';

void main() {
  group('derivePool', () {
    test('no filters → full country list', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(),
        cookedCountries: const {},
        recentPicks: const [],
      );
      expect(pool.length, kCountries.length);
    });

    test('continent filter narrows to selected continents', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(continents: {'Europe'}),
        cookedCountries: const {},
        recentPicks: const [],
      );
      expect(pool, isNotEmpty);
      expect(pool.every((c) => c.continent == 'Europe'), isTrue);
      expect(pool.any((c) => c.name == 'Italy'), isTrue);
      expect(pool.any((c) => c.name == 'Japan'), isFalse);
    });

    test('multiple continents are unioned (OR), not intersected', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(
          continents: {'Europe', 'Oceania'},
        ),
        cookedCountries: const {},
        recentPicks: const [],
      );
      final continents = pool.map((c) => c.continent).toSet();
      expect(continents, {'Europe', 'Oceania'});
    });

    test('undiscoveredOnly excludes cooked countries', () {
      final cooked = {'Italy', 'Japan'};
      final pool = derivePool(
        filter: const DiscoverFilterState(undiscoveredOnly: true),
        cookedCountries: cooked,
        recentPicks: const [],
      );
      expect(pool.any((c) => c.name == 'Italy'), isFalse);
      expect(pool.any((c) => c.name == 'Japan'), isFalse);
      expect(pool.length, kCountries.length - cooked.length);
    });

    test('undiscoveredOnly off keeps cooked countries in pool', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(),
        cookedCountries: const {'Italy'},
        recentPicks: const [],
      );
      expect(pool.any((c) => c.name == 'Italy'), isTrue);
    });

    test('excludeRecent removes session picks from pool', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(excludeRecent: true),
        cookedCountries: const {},
        recentPicks: const ['France', 'Peru'],
      );
      expect(pool.any((c) => c.name == 'France'), isFalse);
      expect(pool.any((c) => c.name == 'Peru'), isFalse);
      expect(pool.length, kCountries.length - 2);
    });

    test('filters compose: continent + undiscovered + excludeRecent', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(
          continents: {'Europe'},
          undiscoveredOnly: true,
          excludeRecent: true,
        ),
        cookedCountries: const {'Italy', 'France'},
        recentPicks: const ['Spain'],
      );
      expect(pool.every((c) => c.continent == 'Europe'), isTrue);
      expect(pool.any((c) => c.name == 'Italy'), isFalse);
      expect(pool.any((c) => c.name == 'France'), isFalse);
      expect(pool.any((c) => c.name == 'Spain'), isFalse);
    });

    test('returns empty list when filters exclude everything', () {
      final cookedAll = kCountries.map((c) => c.name).toSet();
      final pool = derivePool(
        filter: const DiscoverFilterState(undiscoveredOnly: true),
        cookedCountries: cookedAll,
        recentPicks: const [],
      );
      expect(pool, isEmpty);
    });
  });

  group('DiscoverFilterState', () {
    test('activeCount tracks each independent filter', () {
      const empty = DiscoverFilterState();
      expect(empty.activeCount, 0);
      expect(empty.isActive, isFalse);

      const only = DiscoverFilterState(undiscoveredOnly: true);
      expect(only.activeCount, 1);

      const all = DiscoverFilterState(
        continents: {'Asia'},
        undiscoveredOnly: true,
        excludeRecent: true,
      );
      expect(all.activeCount, 3);
      expect(all.isActive, isTrue);
    });

    test('continents counts as one filter regardless of size', () {
      const f = DiscoverFilterState(continents: {'Asia', 'Africa', 'Europe'});
      expect(f.activeCount, 1);
    });
  });
}
