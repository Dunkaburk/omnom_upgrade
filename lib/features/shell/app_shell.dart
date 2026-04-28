import 'package:flutter/material.dart';

import '../diary/diary_journal_screen.dart';
import '../other/other_placeholder.dart';
import '../recipes/recipes_placeholder.dart';
import 'bottom_tab_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.diary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tab.index,
                children: const [
                  DiaryJournalScreen(),
                  RecipesPlaceholder(),
                  OtherPlaceholder(),
                ],
              ),
            ),
            BottomTabBar(
              current: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ],
        ),
      ),
    );
  }
}
