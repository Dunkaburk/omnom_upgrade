import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/diary_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/list_card_actions.dart';
import 'diary_detail_screen.dart';
import 'diary_form_screen.dart';
import 'widgets/diary_card.dart';
import 'widgets/diary_empty_state.dart';
import 'widgets/diary_header.dart';
import 'widgets/sort_filter_button.dart';
import 'widgets/sort_filter_sheet.dart';

class DiaryJournalScreen extends ConsumerWidget {
  const DiaryJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryEntriesProvider);
    final filter = ref.watch(diaryFilterProvider);
    final sorted = ref.watch(sortedDiaryEntriesProvider);
    final totalCount = entriesAsync.valueOrNull?.length ?? 0;

    return ColoredBox(
      color: AppColors.cream,
      child: Column(
        children: [
          // Sticky header (logo + count + "+ New" + sort/filter trigger)
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                DiaryHeader(
                  entryCount: totalCount,
                  onNew: () => _openNewEntry(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: SortFilterButton(
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
                    'Failed to load diary: $e',
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
                    return ListCardActions(
                      key: ValueKey('diary-${entry.id}'),
                      itemKey: ValueKey('diary-dismiss-${entry.id}'),
                      title: entry.title.isEmpty ? 'Untitled' : entry.title,
                      kind: 'entry',
                      onDelete: () => ref
                          .read(diaryEntriesProvider.notifier)
                          .remove(entry.id),
                      child: DiaryCard(
                        entry: entry,
                        onTap: () => _openDetail(context, entry.id),
                      ),
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
