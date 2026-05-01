import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/recipe_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/edit_mode_button.dart';
import '../../widgets/list_card_actions.dart';
import '../../widgets/sort_filter_button.dart';
import 'recipe_add_chooser_screen.dart';
import 'recipe_detail_screen.dart';
import 'widgets/recipe_card.dart';
import 'widgets/recipe_sort_filter_sheet.dart';

class RecipesListScreen extends ConsumerStatefulWidget {
  const RecipesListScreen({super.key});

  @override
  ConsumerState<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends ConsumerState<RecipesListScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final sorted = ref.watch(sortedRecipesProvider);
    final filter = ref.watch(recipeFilterProvider);
    final sortKey = ref.watch(recipeSortProvider);
    final accent = ref.watch(accentColorProvider);
    final totalCount = recipesAsync.valueOrNull?.length ?? 0;
    final canReorder =
        sortKey == 'recent' && !filter.isActive && !_editMode;

    return ColoredBox(
      color: AppColors.cream,
      child: Column(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Recipes',
                              style: AppTextStyles.screenTitle(size: 22)
                                  .copyWith(height: 1.1),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$totalCount saved',
                              style: AppTextStyles.body(
                                size: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (totalCount > 0) ...[
                        EditModeButton(
                          editing: _editMode,
                          accent: accent,
                          onTap: () =>
                              setState(() => _editMode = !_editMode),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _AddButton(
                        accent: accent,
                        onTap: () => _openChooser(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: OmnomSortFilterButton(
                    sortLabel: recipeSortByKey(sortKey).label,
                    filterCount: filter.count,
                    accent: accent,
                    onTap: () => showRecipeSortFilterSheet(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: recipesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.muted),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load recipes: $e',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: AppColors.muted),
                  ),
                ),
              ),
              data: (_) {
                if (sorted.isEmpty) {
                  return _EmptyState(filtersActive: filter.isActive);
                }
                if (canReorder) {
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    itemCount: sorted.length,
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, _, __) => Material(
                      elevation: 6,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: child,
                    ),
                    onReorder: (oldIndex, newIndex) => ref
                        .read(recipesProvider.notifier)
                        .move(oldIndex, newIndex),
                    itemBuilder: (context, i) {
                      final r = sorted[i];
                      return Padding(
                        key: ValueKey('recipe-${r.id}'),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListCardActions(
                          itemKey: ValueKey('recipe-dismiss-${r.id}'),
                          title: r.title.isEmpty ? 'Untitled' : r.title,
                          kind: 'recipe',
                          enableLongPress: false,
                          onDelete: () => ref
                              .read(recipesProvider.notifier)
                              .remove(r.id),
                          child: ReorderableDelayedDragStartListener(
                            index: i,
                            child: RecipeCard(
                              recipe: r,
                              onTap: () => _openDetail(context, r.id),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = sorted[i];
                    final card = RecipeCard(
                      recipe: r,
                      onTap: () => _openDetail(context, r.id),
                    );
                    if (_editMode) {
                      return Row(
                        children: [
                          Expanded(child: card),
                          const SizedBox(width: 10),
                          TrashButton(
                            itemTitle: r.title.isEmpty ? 'this recipe' : r.title,
                            onTap: () => _confirmAndDelete(
                              context,
                              ref,
                              r.id,
                              r.title,
                            ),
                          ),
                        ],
                      );
                    }
                    return ListCardActions(
                      key: ValueKey('recipe-${r.id}'),
                      itemKey: ValueKey('recipe-dismiss-${r.id}'),
                      title: r.title.isEmpty ? 'Untitled' : r.title,
                      kind: 'recipe',
                      onDelete: () =>
                          ref.read(recipesProvider.notifier).remove(r.id),
                      child: card,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) async {
    final ok = await confirmDelete(
      context,
      title: title.isEmpty ? 'Untitled' : title,
      kind: 'recipe',
    );
    if (ok) {
      await ref.read(recipesProvider.notifier).remove(id);
      if (mounted &&
          (ref.read(recipesProvider).valueOrNull ?? const []).isEmpty) {
        setState(() => _editMode = false);
      }
    }
  }

  void _openChooser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const RecipeAddChooserScreen(),
      ),
    );
  }

  void _openDetail(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailScreen(recipeId: id),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
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
        color: accent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '+',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Add',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.filtersActive = false});

  final bool filtersActive;

  @override
  Widget build(BuildContext context) {
    final title = filtersActive ? 'No recipes match' : 'No recipes yet';
    final body = filtersActive
        ? 'Try clearing some filters to see more.'
        : 'Tap + Add to save your first recipe.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.screenTitle(size: 16)),
            const SizedBox(height: 6),
            Text(
              body,
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
