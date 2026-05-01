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
        filter: const DiscoverFilterState(continents: {'Europa'}),
        cookedCountries: const {},
        recentPicks: const [],
      );
      expect(pool, isNotEmpty);
      expect(pool.every((c) => c.continent == 'Europa'), isTrue);
      expect(pool.any((c) => c.name == 'Italien'), isTrue);
      expect(pool.any((c) => c.name == 'Japan'), isFalse);
    });

    test('multiple continents are unioned (OR), not intersected', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(
          continents: {'Europa', 'Oceanien'},
        ),
        cookedCountries: const {},
        recentPicks: const [],
      );
      final continents = pool.map((c) => c.continent).toSet();
      expect(continents, {'Europa', 'Oceanien'});
    });

    test('undiscoveredOnly excludes cooked countries', () {
      final cooked = {'Italien', 'Japan'};
      final pool = derivePool(
        filter: const DiscoverFilterState(undiscoveredOnly: true),
        cookedCountries: cooked,
        recentPicks: const [],
      );
      expect(pool.any((c) => c.name == 'Italien'), isFalse);
      expect(pool.any((c) => c.name == 'Japan'), isFalse);
      expect(pool.length, kCountries.length - cooked.length);
    });

    test('undiscoveredOnly off keeps cooked countries in pool', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(),
        cookedCountries: const {'Italien'},
        recentPicks: const [],
      );
      expect(pool.any((c) => c.name == 'Italien'), isTrue);
    });

    test('excludeRecent removes session picks from pool', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(excludeRecent: true),
        cookedCountries: const {},
        recentPicks: const ['Frankrike', 'Peru'],
      );
      expect(pool.any((c) => c.name == 'Frankrike'), isFalse);
      expect(pool.any((c) => c.name == 'Peru'), isFalse);
      expect(pool.length, kCountries.length - 2);
    });

    test('filters compose: continent + undiscovered + excludeRecent', () {
      final pool = derivePool(
        filter: const DiscoverFilterState(
          continents: {'Europa'},
          undiscoveredOnly: true,
          excludeRecent: true,
        ),
        cookedCountries: const {'Italien', 'Frankrike'},
        recentPicks: const ['Spanien'],
      );
      expect(pool.every((c) => c.continent == 'Europa'), isTrue);
      expect(pool.any((c) => c.name == 'Italien'), isFalse);
      expect(pool.any((c) => c.name == 'Frankrike'), isFalse);
      expect(pool.any((c) => c.name == 'Spanien'), isFalse);
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
        continents: {'Asien'},
        undiscoveredOnly: true,
        excludeRecent: true,
      );
      expect(all.activeCount, 3);
      expect(all.isActive, isTrue);
    });

    test('continents counts as one filter regardless of size', () {
      const f =
          DiscoverFilterState(continents: {'Asien', 'Afrika', 'Europa'});
      expect(f.activeCount, 1);
    });
  });
}
