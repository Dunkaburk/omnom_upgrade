import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

class OtherPlaceholder extends StatelessWidget {
  const OtherPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Discover', style: AppTextStyles.screenTitle()),
            const SizedBox(height: 8),
            Text(
              'Coming in the next phase.',
              style: AppTextStyles.body(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
