import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_tab_provider.dart';
import '../diary/diary_journal_screen.dart';
import '../other/other_placeholder.dart';
import '../recipes/recipes_list_screen.dart';
import 'bottom_tab_bar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(appTabStateProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: tab.index,
                children: const [
                  DiaryJournalScreen(),
                  RecipesListScreen(),
                  OtherPlaceholder(),
                ],
              ),
            ),
            BottomTabBar(
              current: tab,
              onChanged: (t) =>
                  ref.read(appTabStateProvider.notifier).set(t),
            ),
          ],
        ),
      ),
    );
  }
}
