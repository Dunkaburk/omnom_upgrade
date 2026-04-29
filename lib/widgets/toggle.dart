import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Row with a label / optional sub-label and a 42×24 pill toggle on the right.
/// Mirrors the prototype's `Toggle` (Omnom.html lines 1055–1065).
class OmnomToggle extends StatelessWidget {
  const OmnomToggle({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
    this.sub,
    this.showBottomBorder = true,
  });

  final String label;
  final String? sub;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showBottomBorder
              ? const Border(bottom: BorderSide(color: AppColors.border))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body(
                        size: 14,
                        weight: value ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: AppTextStyles.small(size: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ToggleSwitch(value: value, accent: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({required this.value, required this.accent});

  final bool value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 24,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 24,
            decoration: BoxDecoration(
              color: value ? accent : AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: 3,
            left: value ? 21 : 3,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
