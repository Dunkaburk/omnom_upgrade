import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class DiaryHeader extends ConsumerWidget {
  const DiaryHeader({
    super.key,
    required this.entryCount,
    required this.onNew,
  });

  final int entryCount;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'omnom',
                  style: AppTextStyles.brandLogo(color: accent).copyWith(
                    letterSpacing: -0.02 * 26,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$entryCount ${entryCount == 1 ? 'entry' : 'entries'} logged',
                  style: AppTextStyles.small(size: 12),
                ),
              ],
            ),
          ),
          _NewButton(accent: accent, onTap: onNew),
        ],
      ),
    );
  }
}

class _NewButton extends StatelessWidget {
  const _NewButton({required this.accent, required this.onTap});
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0x44 / 0xFF),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+',
                  style: AppTextStyles.body(
                    size: 18,
                    color: AppColors.white,
                    weight: FontWeight.w500,
                  ).copyWith(height: 1),
                ),
                const SizedBox(width: 6),
                Text(
                  'New',
                  style: AppTextStyles.body(
                    size: 13,
                    color: AppColors.white,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
