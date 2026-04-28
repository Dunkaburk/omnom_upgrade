import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settings.dart';
import '../theme/colors.dart';
import 'repositories.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  Future<Settings> build() async =>
      ref.read(settingsRepositoryProvider).load();

  Future<void> save(Settings next) async {
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

@riverpod
Color accentColor(AccentColorRef ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull;
  if (settings == null) return AppColors.defaultAccent;
  return HexColor.fromHex(settings.accentHex);
}

@riverpod
({String person1, String person2}) people(PeopleRef ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull ??
      const Settings();
  return (person1: settings.person1, person2: settings.person2);
}
