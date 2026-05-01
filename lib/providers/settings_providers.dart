import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settings.dart';
import '../theme/colors.dart';
import 'repositories.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  StreamSubscription<Settings>? _sub;

  @override
  Future<Settings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    ref.onDispose(() => _sub?.cancel());
    final completer = Completer<Settings>();
    _sub = repo.watch().listen(
      (settings) {
        if (!completer.isCompleted) {
          completer.complete(settings);
        } else {
          state = AsyncData(settings);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          state = AsyncError(error, stack);
        }
      },
    );
    return completer.future;
  }

  Future<void> save(Settings next) async {
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
