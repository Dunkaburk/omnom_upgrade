// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accentColorHash() => r'fd782eb50cb788dbd899fb57d548796a8dc36ec8';

/// See also [accentColor].
@ProviderFor(accentColor)
final accentColorProvider = AutoDisposeProvider<Color>.internal(
  accentColor,
  name: r'accentColorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accentColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccentColorRef = AutoDisposeProviderRef<Color>;
String _$peopleHash() => r'7061fae4f392905a008fe4a41057f5e92bcd2854';

/// See also [people].
@ProviderFor(people)
final peopleProvider =
    AutoDisposeProvider<({String person1, String person2})>.internal(
  people,
  name: r'peopleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$peopleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PeopleRef = AutoDisposeProviderRef<({String person1, String person2})>;
String _$settingsControllerHash() =>
    r'0ca3bd6eb7e6deaecfef17c2de599c83b8a2a812';

/// See also [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, Settings>.internal(
  SettingsController.new,
  name: r'settingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsController = AsyncNotifier<Settings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
