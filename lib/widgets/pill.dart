import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Shared pill button. Used across the sort/filter sheet.
/// Mirrors the React `Pill` component (Omnom.html lines 105–113).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
    this.small = true,
  });

  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.white : AppColors.ink;
    return Material(
      color: active ? accent : AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: small
              ? const EdgeInsets.symmetric(horizontal: 11, vertical: 5)
              : const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: active
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            label,
            style: AppTextStyles.body(
              size: small ? 11 : 13,
              color: fg,
              weight: active ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
