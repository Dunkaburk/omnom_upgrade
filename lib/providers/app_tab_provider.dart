import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/shell/bottom_tab_bar.dart';

part 'app_tab_provider.g.dart';

@Riverpod(keepAlive: true)
class AppTabState extends _$AppTabState {
  @override
  AppTab build() => AppTab.diary;

  void set(AppTab tab) => state = tab;
}
