import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/diary_entry.dart';
import '../utils/formatters.dart';
import 'repositories.dart';

part 'diary_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sort options — in-order list with stable keys + display labels.
// Mirrors SORT_OPTIONS from Omnom.html lines 154–167.
// ─────────────────────────────────────────────────────────────────────────────

class SortOption {
  final String key;
  final String label;
  final String group;
  const SortOption(this.key, this.label, this.group);
}

const List<SortOption> kSortOptions = [
  SortOption('date_desc', 'Newest first', 'Date'),
  SortOption('date_asc', 'Oldest first', 'Date'),
  SortOption('rating_desc', 'Highest rated', 'Rating'),
  SortOption('rating_asc', 'Lowest rated', 'Rating'),
  SortOption('active_asc', 'Quickest (active)', 'Time'),
  SortOption('active_desc', 'Longest (active)', 'Time'),
  SortOption('total_asc', 'Quickest (total)', 'Time'),
  SortOption('total_desc', 'Longest (total)', 'Time'),
  SortOption('price_asc', 'Cheapest first', 'Price'),
  SortOption('price_desc', 'Most expensive', 'Price'),
  SortOption('meal', 'Meal type (A–Z)', 'Other'),
  SortOption('title', 'Title (A–Z)', 'Other'),
];

const List<String> kMealTypes = [
  'Breakfast',
  'Lunch',
  'Dinner',
  'Snack',
  'Other',
];

SortOption sortByKey(String key) =>
    kSortOptions.firstWhere((o) => o.key == key, orElse: () => kSortOptions.first);

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class DiaryEntries extends _$DiaryEntries {
  @override
  Future<List<DiaryEntry>> build() async =>
      ref.read(diaryRepositoryProvider).load();

  Future<void> add(DiaryEntry entry) async {
    final next = [entry, ...?state.valueOrNull];
    state = AsyncData(next);
    await ref.read(diaryRepositoryProvider).save(next);
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final current = state.valueOrNull ?? const [];
    final next = [
      for (final e in current) if (e.id == entry.id) entry else e,
    ];
    state = AsyncData(next);
    await ref.read(diaryRepositoryProvider).save(next);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? const [];
    final next = current.where((e) => e.id != id).toList();
    state = AsyncData(next);
    await ref.read(diaryRepositoryProvider).save(next);
  }

  Future<void> move(int oldIndex, int newIndex) async {
    final current = [...?state.valueOrNull];
    if (oldIndex < 0 || oldIndex >= current.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > current.length) target = current.length;
    final entry = current.removeAt(oldIndex);
    current.insert(target, entry);
    state = AsyncData(current);
    await ref.read(diaryRepositoryProvider).save(current);
  }
}

@riverpod
class DiarySort extends _$DiarySort {
  @override
  String build() => 'date_desc';
  void set(String key) => state = key;
}

class DiaryFilterState {
  final String meal; // empty string = no filter
  final List<String> tags;
  const DiaryFilterState({this.meal = '', this.tags = const []});

  DiaryFilterState copyWith({String? meal, List<String>? tags}) =>
      DiaryFilterState(meal: meal ?? this.meal, tags: tags ?? this.tags);

  int get count =>
      (meal.isEmpty ? 0 : 1) + tags.length;

  bool get isActive => count > 0;

  DiaryFilterState toggleTag(String tag) {
    if (tags.contains(tag)) {
      return copyWith(tags: tags.where((t) => t != tag).toList());
    }
    return copyWith(tags: [...tags, tag]);
  }
}

@riverpod
class DiaryFilter extends _$DiaryFilter {
  @override
  DiaryFilterState build() => const DiaryFilterState();

  void setMeal(String meal) => state = state.copyWith(meal: meal);
  void toggleTag(String tag) => state = state.toggleTag(tag);
  void clear() => state = const DiaryFilterState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Derived
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
List<String> allTags(AllTagsRef ref) {
  final entries = ref.watch(diaryEntriesProvider).valueOrNull ?? const [];
  final set = <String>{};
  for (final e in entries) {
    set.addAll(e.tags);
  }
  final list = set.toList()..sort();
  return list;
}

@riverpod
List<DiaryEntry> sortedDiaryEntries(SortedDiaryEntriesRef ref) {
  final entries = ref.watch(diaryEntriesProvider).valueOrNull ?? const [];
  final sortKey = ref.watch(diarySortProvider);
  final filter = ref.watch(diaryFilterProvider);

  final filtered = entries.where((e) {
    if (filter.meal.isNotEmpty && e.meal != filter.meal) return false;
    if (filter.tags.isNotEmpty &&
        !filter.tags.every((t) => e.tags.contains(t))) {
      return false;
    }
    return true;
  }).toList();

  int byDate(DiaryEntry a, DiaryEntry b) => a.date.compareTo(b.date);
  int byActive(DiaryEntry a, DiaryEntry b) =>
      (a.activeTime ?? -1).compareTo(b.activeTime ?? -1);
  int byTotal(DiaryEntry a, DiaryEntry b) =>
      ((a.activeTime ?? 0) + (a.passiveTime ?? 0))
          .compareTo((b.activeTime ?? 0) + (b.passiveTime ?? 0));
  int byPrice(DiaryEntry a, DiaryEntry b) =>
      (a.price ?? -1).compareTo(b.price ?? -1);
  int byRating(DiaryEntry a, DiaryEntry b) =>
      avgRatingValue(a.r1, a.r2).compareTo(avgRatingValue(b.r1, b.r2));

  final sorted = [...filtered];
  switch (sortKey) {
    case 'date_asc':
      sorted.sort(byDate);
    case 'date_desc':
      sorted.sort((a, b) => byDate(b, a));
    case 'rating_desc':
      sorted.sort((a, b) => byRating(b, a));
    case 'rating_asc':
      sorted.sort(byRating);
    case 'active_asc':
      sorted.sort(byActive);
    case 'active_desc':
      sorted.sort((a, b) => byActive(b, a));
    case 'total_asc':
      sorted.sort(byTotal);
    case 'total_desc':
      sorted.sort((a, b) => byTotal(b, a));
    case 'price_asc':
      sorted.sort(byPrice);
    case 'price_desc':
      sorted.sort((a, b) => byPrice(b, a));
    case 'meal':
      sorted.sort((a, b) => a.meal.compareTo(b.meal));
    case 'title':
      sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    default:
      sorted.sort((a, b) => byDate(b, a));
  }
  return sorted;
}
