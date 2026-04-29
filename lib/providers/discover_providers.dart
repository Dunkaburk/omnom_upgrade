import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/countries.dart';
import 'diary_providers.dart';

part 'discover_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────────────────────────────────────

class DiscoverFilterState {
  final Set<String> continents;
  final bool undiscoveredOnly;
  final bool excludeRecent;

  const DiscoverFilterState({
    this.continents = const <String>{},
    this.undiscoveredOnly = false,
    this.excludeRecent = false,
  });

  DiscoverFilterState copyWith({
    Set<String>? continents,
    bool? undiscoveredOnly,
    bool? excludeRecent,
  }) =>
      DiscoverFilterState(
        continents: continents ?? this.continents,
        undiscoveredOnly: undiscoveredOnly ?? this.undiscoveredOnly,
        excludeRecent: excludeRecent ?? this.excludeRecent,
      );

  int get activeCount =>
      (continents.isNotEmpty ? 1 : 0) +
      (undiscoveredOnly ? 1 : 0) +
      (excludeRecent ? 1 : 0);

  bool get isActive => activeCount > 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Roulette state
// ─────────────────────────────────────────────────────────────────────────────

class DiscoverState {
  final String? currentPick;
  final bool spinning;
  final List<String> recentPicks; // max 5, newest-first
  final DiscoverFilterState filter;

  const DiscoverState({
    this.currentPick,
    this.spinning = false,
    this.recentPicks = const [],
    this.filter = const DiscoverFilterState(),
  });

  DiscoverState copyWith({
    Object? currentPick = _sentinel,
    bool? spinning,
    List<String>? recentPicks,
    DiscoverFilterState? filter,
  }) =>
      DiscoverState(
        currentPick:
            currentPick == _sentinel ? this.currentPick : currentPick as String?,
        spinning: spinning ?? this.spinning,
        recentPicks: recentPicks ?? this.recentPicks,
        filter: filter ?? this.filter,
      );
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// Pure pool derivation — exposed for tests.
// ─────────────────────────────────────────────────────────────────────────────

List<Country> derivePool({
  required DiscoverFilterState filter,
  required Set<String> cookedCountries,
  required List<String> recentPicks,
}) {
  Iterable<Country> list = kCountries;
  if (filter.continents.isNotEmpty) {
    list = list.where((c) => filter.continents.contains(c.continent));
  }
  if (filter.undiscoveredOnly) {
    list = list.where((c) => !cookedCountries.contains(c.name));
  }
  if (filter.excludeRecent) {
    final recent = recentPicks.toSet();
    list = list.where((c) => !recent.contains(c.name));
  }
  return list.toList(growable: false);
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Set of country names already logged in the diary (trimmed, raw equality —
/// the prototype does plain `Set.has`, no case-folding or accent stripping).
@riverpod
Set<String> cookedCountries(CookedCountriesRef ref) {
  final entries = ref.watch(diaryEntriesProvider).valueOrNull ?? const [];
  final set = <String>{};
  for (final e in entries) {
    final c = e.country?.trim() ?? '';
    if (c.isNotEmpty) set.add(c);
  }
  return set;
}

@Riverpod(keepAlive: true)
class DiscoverController extends _$DiscoverController {
  Random _rng = Random();

  @override
  DiscoverState build() => const DiscoverState();

  /// Replace the RNG — used by tests for determinism.
  // ignore: use_setters_to_change_properties
  void debugSetRandom(Random rng) => _rng = rng;

  List<Country> _currentPool() => derivePool(
        filter: state.filter,
        cookedCountries: ref.read(cookedCountriesProvider),
        recentPicks: state.recentPicks,
      );

  /// Pick once synchronously. Used as a fallback for the test environment;
  /// the screen drives the 12-cycle spin via `cycleTo` + `commit`.
  void spinOnce() {
    final pool = _currentPool();
    if (pool.isEmpty || state.spinning) return;
    final pick = pool[_rng.nextInt(pool.length)].name;
    _commit(pick);
  }

  /// Begin a spin. The screen owns the `Timer.periodic` and calls back via
  /// `cycleTo` for each visible cycle, then `commit` for the final pick.
  bool beginSpin() {
    if (state.spinning) return false;
    if (_currentPool().isEmpty) return false;
    state = state.copyWith(spinning: true);
    return true;
  }

  /// Random country name from the active pool, or null if empty.
  String? randomFromPool() {
    final pool = _currentPool();
    if (pool.isEmpty) return null;
    return pool[_rng.nextInt(pool.length)].name;
  }

  void cycleTo(String name) {
    state = state.copyWith(currentPick: name);
  }

  void commit(String pick) {
    _commit(pick);
  }

  void cancelSpin() {
    if (!state.spinning) return;
    state = state.copyWith(spinning: false);
  }

  void _commit(String pick) {
    final next = [pick, ...state.recentPicks.where((x) => x != pick)]
        .take(5)
        .toList(growable: false);
    state = state.copyWith(
      currentPick: pick,
      spinning: false,
      recentPicks: next,
    );
  }

  void toggleContinent(String continent) {
    final cur = state.filter.continents;
    final next = cur.contains(continent)
        ? (cur.toSet()..remove(continent))
        : (cur.toSet()..add(continent));
    state = state.copyWith(
      filter: state.filter.copyWith(continents: next),
    );
  }

  void setUndiscoveredOnly(bool value) {
    state = state.copyWith(
      filter: state.filter.copyWith(undiscoveredOnly: value),
    );
  }

  void setExcludeRecent(bool value) {
    state = state.copyWith(
      filter: state.filter.copyWith(excludeRecent: value),
    );
  }

  void clearFilters() {
    state = state.copyWith(filter: const DiscoverFilterState());
  }
}

/// Live pool derived from filters + diary state + session recents.
@riverpod
List<Country> discoverPool(DiscoverPoolRef ref) {
  final s = ref.watch(discoverControllerProvider);
  final cooked = ref.watch(cookedCountriesProvider);
  return derivePool(
    filter: s.filter,
    cookedCountries: cooked,
    recentPicks: s.recentPicks,
  );
}
