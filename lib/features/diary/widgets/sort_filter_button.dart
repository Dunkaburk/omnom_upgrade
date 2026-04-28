import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/diary_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class SortFilterButton extends ConsumerWidget {
  const SortFilterButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final sortKey = ref.watch(diarySortProvider);
    final filter = ref.watch(diaryFilterProvider);

    final hasFilters = filter.isActive;
    final activeSort = sortByKey(sortKey);
    final filterCount = filter.count;

    final fg = hasFilters ? accent : AppColors.muted;
    final bg = hasFilters
        ? accent.withValues(alpha: 0x18 / 0xFF)
        : AppColors.creamDark;
    final borderColor = hasFilters
        ? accent.withValues(alpha: 0x44 / 0xFF)
        : AppColors.border;

    final label = filterCount > 0
        ? '${activeSort.label} · $filterCount filter${filterCount == 1 ? '' : 's'}'
        : activeSort.label;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CustomPaint(
                size: const Size(14, 14),
                painter: _SortIconPainter(fg),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body(size: 12, color: fg),
                ),
              ),
              Text(
                '▾',
                style: AppTextStyles.body(size: 10, color: fg).copyWith(
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortIconPainter extends CustomPainter {
  _SortIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(1, 3), const Offset(13, 3), p)
      ..drawLine(const Offset(3, 7), const Offset(11, 7), p)
      ..drawLine(const Offset(5, 11), const Offset(9, 11), p);
  }

  @override
  bool shouldRepaint(covariant _SortIconPainter old) => old.color != color;
}
