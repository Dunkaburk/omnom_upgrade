import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.sectionLabel(color: AppColors.muted);
    final upper = text.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: upper),
            if (optional)
              TextSpan(
                text: ' (valfritt)',
                style: AppTextStyles.body(
                  size: 10.5,
                  color: AppColors.muted,
                  weight: FontWeight.w400,
                ).copyWith(letterSpacing: 0),
              ),
          ],
        ),
      ),
    );
  }
}
