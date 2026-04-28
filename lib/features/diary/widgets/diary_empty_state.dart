import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class DiaryEmptyState extends StatelessWidget {
  const DiaryEmptyState({super.key, required this.filtersActive});

  final bool filtersActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'Nothing here yet',
              style: AppTextStyles.screenTitle(size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              filtersActive
                  ? 'Try adjusting your filters.'
                  : 'Tap + New to log your first meal.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(size: 13, color: AppColors.muted)
                  .copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
