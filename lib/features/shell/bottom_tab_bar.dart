import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import 'tab_icons.dart';

enum AppTab { diary, recipes, other }

class BottomTabBar extends ConsumerWidget {
  const BottomTabBar({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final AppTab current;
  final ValueChanged<AppTab> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: AppTab.values
                .map((t) => Expanded(
                      child: _TabButton(
                        tab: t,
                        active: current == t,
                        accent: accent,
                        onTap: () => onChanged(t),
                      ),
                    ))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final AppTab tab;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  String get _label => switch (tab) {
        AppTab.diary => 'Diary',
        AppTab.recipes => 'Recipes',
        AppTab.other => 'Other',
      };

  Widget _buildIcon(Color color) => switch (tab) {
        AppTab.diary => DiaryTabIcon(color: color),
        AppTab.recipes => RecipesTabIcon(color: color, active: active),
        AppTab.other => OtherTabIcon(color: color),
      };

  @override
  Widget build(BuildContext context) {
    final color = active ? accent : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(color),
            const SizedBox(height: 4),
            Text(
              _label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                color: color,
                letterSpacing: 0.03 * 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
