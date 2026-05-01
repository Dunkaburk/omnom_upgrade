import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/diary_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/edit_mode_button.dart';
import '../../widgets/list_card_actions.dart';
import '../../widgets/sort_filter_button.dart';
import 'diary_detail_screen.dart';
import 'diary_form_screen.dart';
import 'widgets/diary_card.dart';
import 'widgets/diary_empty_state.dart';
import 'widgets/diary_header.dart';
import 'widgets/sort_filter_sheet.dart';

class DiaryJournalScreen extends ConsumerStatefulWidget {
  const DiaryJournalScreen({super.key});

  @override
  ConsumerState<DiaryJournalScreen> createState() =>
      _DiaryJournalScreenState();
}

class _DiaryJournalScreenState extends ConsumerState<DiaryJournalScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(diaryEntriesProvider);
    final filter = ref.watch(diaryFilterProvider);
    final sortKey = ref.watch(diarySortProvider);
    final sorted = ref.watch(sortedDiaryEntriesProvider);
    final accent = ref.watch(accentColorProvider);
    final totalCount = entriesAsync.valueOrNull?.length ?? 0;

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
                DiaryHeader(
                  entryCount: totalCount,
                  onNew: () => _openNewEntry(context),
                  editing: _editMode,
                  onToggleEdit: totalCount == 0
                      ? null
                      : () => setState(() => _editMode = !_editMode),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: OmnomSortFilterButton(
                    sortLabel: sortByKey(sortKey).label,
                    filterCount: filter.count,
                    accent: accent,
                    onTap: () => showSortFilterSheet(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.muted),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Kunde inte ladda logg: $e',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(color: AppColors.muted),
                  ),
                ),
              ),
              data: (_) {
                if (sorted.isEmpty) {
                  return DiaryEmptyState(filtersActive: filter.isActive);
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final entry = sorted[i];
                    final card = DiaryCard(
                      entry: entry,
                      onTap: () => _openDetail(context, entry.id),
                    );
                    if (_editMode) {
                      return Row(
                        key: ValueKey('diary-edit-${entry.id}'),
                        children: [
                          Expanded(child: card),
                          const SizedBox(width: 10),
                          TrashButton(
                            itemTitle: entry.title.isEmpty
                                ? 'det här inlägget'
                                : entry.title,
                            onTap: () => _confirmAndDelete(
                              context,
                              ref,
                              entry.id,
                              entry.title,
                            ),
                          ),
                        ],
                      );
                    }
                    return ListCardActions(
                      key: ValueKey('diary-${entry.id}'),
                      itemKey: ValueKey('diary-dismiss-${entry.id}'),
                      title: entry.title.isEmpty ? 'Namnlöst' : entry.title,
                      kind: 'inlägget',
                      onDelete: () => ref
                          .read(diaryEntriesProvider.notifier)
                          .remove(entry.id),
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
      title: title.isEmpty ? 'Namnlöst' : title,
      kind: 'inlägget',
    );
    if (ok) {
      await ref.read(diaryEntriesProvider.notifier).remove(id);
      if (mounted &&
          (ref.read(diaryEntriesProvider).valueOrNull ?? const []).isEmpty) {
        setState(() => _editMode = false);
      }
    }
  }

  void _openNewEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const DiaryFormScreen(),
      ),
    );
  }

  void _openDetail(BuildContext context, String entryId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DiaryDetailScreen(entryId: entryId),
      ),
    );
  }
}
