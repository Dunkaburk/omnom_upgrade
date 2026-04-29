// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cookedCountriesHash() => r'd0703f7d83931593a6e0b6280bb16ed40fcb7b3d';

/// Set of country names already logged in the diary (trimmed, raw equality —
/// the prototype does plain `Set.has`, no case-folding or accent stripping).
///
/// Copied from [cookedCountries].
@ProviderFor(cookedCountries)
final cookedCountriesProvider = AutoDisposeProvider<Set<String>>.internal(
  cookedCountries,
  name: r'cookedCountriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cookedCountriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CookedCountriesRef = AutoDisposeProviderRef<Set<String>>;
String _$discoverPoolHash() => r'5d5941bddc4fe932e60d84f17f1f3d42dadee714';

/// Live pool derived from filters + diary state + session recents.
///
/// Copied from [discoverPool].
@ProviderFor(discoverPool)
final discoverPoolProvider = AutoDisposeProvider<List<Country>>.internal(
  discoverPool,
  name: r'discoverPoolProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$discoverPoolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiscoverPoolRef = AutoDisposeProviderRef<List<Country>>;
String _$discoverControllerHash() =>
    r'43abeab3a88926c8400f72b0c6bde3f1914cbfd4';

/// See also [DiscoverController].
@ProviderFor(DiscoverController)
final discoverControllerProvider =
    NotifierProvider<DiscoverController, DiscoverState>.internal(
  DiscoverController.new,
  name: r'discoverControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$discoverControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiscoverController = Notifier<DiscoverState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
