import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/recipe_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/pill.dart';

Future<void> showRecipeSortFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cream,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => const _RecipeSortFilterSheet(),
  );
}

class _RecipeSortFilterSheet extends ConsumerWidget {
  const _RecipeSortFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final sortKey = ref.watch(recipeSortProvider);
    final filter = ref.watch(recipeFilterProvider);
    final tags = ref.watch(allRecipeTagsProvider);
    final countries = ref.watch(allRecipeCountriesProvider);

    final groups = <String, List<RecipeSortOption>>{};
    for (final o in kRecipeSortOptions) {
      groups.putIfAbsent(o.group, () => []).add(o);
    }

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sortera & filtrera',
                      style: AppTextStyles.screenTitle(size: 18),
                    ),
                    const SizedBox(height: 20),
                    for (final group in groups.entries) ...[
                      _Section(
                        label: group.key,
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            for (final o in group.value)
                              Pill(
                                label: o.label,
                                active: sortKey == o.key,
                                accent: accent,
                                onTap: () => ref
                                    .read(recipeSortProvider.notifier)
                                    .set(o.key),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (countries.isNotEmpty || tags.isNotEmpty) ...[
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 16),
                    ],
                    if (countries.isNotEmpty)
                      _Section(
                        label: 'Land',
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            Pill(
                              label: 'Alla',
                              active: filter.country.isEmpty,
                              accent: accent,
                              onTap: () => ref
                                  .read(recipeFilterProvider.notifier)
                                  .setCountry(''),
                            ),
                            for (final c in countries)
                              Pill(
                                label: c,
                                active: filter.country == c,
                                accent: accent,
                                onTap: () => ref
                                    .read(recipeFilterProvider.notifier)
                                    .setCountry(filter.country == c ? '' : c),
                              ),
                          ],
                        ),
                      ),
                    if (tags.isNotEmpty) ...[
                      if (countries.isNotEmpty) const SizedBox(height: 16),
                      _Section(
                        label: 'Taggar',
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            for (final t in tags)
                              Pill(
                                label: t,
                                active: filter.tags.contains(t),
                                accent: accent,
                                onTap: () => ref
                                    .read(recipeFilterProvider.notifier)
                                    .toggleTag(t),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (filter.isActive) ...[
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 16),
                      _ClearFiltersButton(
                        onTap: () =>
                            ref.read(recipeFilterProvider.notifier).clear(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.sectionLabel()),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  const _ClearFiltersButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            'Rensa filter',
            style: AppTextStyles.body(size: 14, color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}
