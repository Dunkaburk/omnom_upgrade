import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/countries.dart';
import '../../../providers/discover_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/section_label.dart';
import '../../../widgets/toggle.dart';

Future<void> showDiscoverFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (_) => const _DiscoverFilterSheet(),
  );
}

class _DiscoverFilterSheet extends ConsumerWidget {
  const _DiscoverFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final state = ref.watch(discoverControllerProvider);
    final controller = ref.read(discoverControllerProvider.notifier);
    final filter = state.filter;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18, top: 4),
                        child: Text(
                          'Filters',
                          style: AppTextStyles.screenTitle(size: 18),
                        ),
                      ),
                      OmnomToggle(
                        label: 'Undiscovered only',
                        sub: 'Exclude countries already in your diary',
                        value: filter.undiscoveredOnly,
                        accent: accent,
                        onChanged: controller.setUndiscoveredOnly,
                      ),
                      OmnomToggle(
                        label: 'Exclude recent picks',
                        sub: 'Skip countries from this session',
                        value: filter.excludeRecent,
                        accent: accent,
                        onChanged: controller.setExcludeRecent,
                      ),
                      const SizedBox(height: 18),
                      const SectionLabel('Continent'),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          for (final cont in kContinents)
                            Pill(
                              label: cont,
                              active: filter.continents.contains(cont),
                              accent: accent,
                              onTap: () => controller.toggleContinent(cont),
                            ),
                        ],
                      ),
                      if (filter.isActive) ...[
                        const SizedBox(height: 18),
                        _ClearFiltersButton(onTap: controller.clearFilters),
                      ],
                    ],
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

class _ClearFiltersButton extends StatelessWidget {
  const _ClearFiltersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Text(
              'Clear all filters',
              style: AppTextStyles.body(
                size: 14,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
