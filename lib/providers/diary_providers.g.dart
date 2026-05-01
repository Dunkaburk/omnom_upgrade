// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allTagsHash() => r'ff73a7acdeb633c371666e9da24d546a5054a9aa';

/// See also [allTags].
@ProviderFor(allTags)
final allTagsProvider = AutoDisposeProvider<List<String>>.internal(
  allTags,
  name: r'allTagsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTagsRef = AutoDisposeProviderRef<List<String>>;
String _$sortedDiaryEntriesHash() =>
    r'e4f640b19c985143ff67a610a469b448bdbb2037';

/// See also [sortedDiaryEntries].
@ProviderFor(sortedDiaryEntries)
final sortedDiaryEntriesProvider =
    AutoDisposeProvider<List<DiaryEntry>>.internal(
  sortedDiaryEntries,
  name: r'sortedDiaryEntriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sortedDiaryEntriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortedDiaryEntriesRef = AutoDisposeProviderRef<List<DiaryEntry>>;
String _$diaryEntriesHash() => r'8c69c3f7154414db8773b33cf7e484895606d88d';

/// See also [DiaryEntries].
@ProviderFor(DiaryEntries)
final diaryEntriesProvider =
    AsyncNotifierProvider<DiaryEntries, List<DiaryEntry>>.internal(
  DiaryEntries.new,
  name: r'diaryEntriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$diaryEntriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiaryEntries = AsyncNotifier<List<DiaryEntry>>;
String _$diarySortHash() => r'7ac848ab20e013e443fe955c92a9f44279e5dcb9';

/// See also [DiarySort].
@ProviderFor(DiarySort)
final diarySortProvider =
    AutoDisposeNotifierProvider<DiarySort, String>.internal(
  DiarySort.new,
  name: r'diarySortProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$diarySortHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiarySort = AutoDisposeNotifier<String>;
String _$diaryFilterHash() => r'ae95feb5b00cbc5560d2e03390d6929ee938e2b7';

/// See also [DiaryFilter].
@ProviderFor(DiaryFilter)
final diaryFilterProvider =
    AutoDisposeNotifierProvider<DiaryFilter, DiaryFilterState>.internal(
  DiaryFilter.new,
  name: r'diaryFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$diaryFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiaryFilter = AutoDisposeNotifier<DiaryFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
