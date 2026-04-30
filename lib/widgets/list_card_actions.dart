import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Wraps a list card with horizontal swipe-to-delete (Dismissible) and a
/// confirm dialog. Long-press shows an action sheet so users on devices
/// where swipe feels awkward can still reach the delete action.
class ListCardActions extends StatelessWidget {
  const ListCardActions({
    super.key,
    required this.itemKey,
    required this.title,
    required this.kind,
    required this.onDelete,
    required this.child,
    this.onReorderHandle,
  });

  /// Stable key for [Dismissible] — usually the item's id.
  final Key itemKey;

  /// Shown in the confirm dialog: "Delete \"<title>\"?"
  final String title;

  /// "entry" or "recipe" — used in confirm copy.
  final String kind;

  final VoidCallback onDelete;
  final Widget child;

  /// When non-null, a long-press also offers a reorder hint via this callback.
  /// Currently unused by callers — placeholder for future drag-handle entry.
  final VoidCallback? onReorderHandle;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB94A48),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline,
                size: 20, color: AppColors.white),
            const SizedBox(width: 6),
            Text(
              'Delete',
              style: AppTextStyles.body(
                size: 14,
                color: AppColors.white,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => confirmDelete(context, title: title, kind: kind),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onLongPress: () => _showActionSheet(context),
        child: child,
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.screenTitle(size: 16),
                ),
              ),
              _SheetButton(
                label: 'Delete $kind',
                tone: _Tone.destructive,
                onTap: () => Navigator.of(sheetCtx).pop('delete'),
              ),
              const SizedBox(height: 8),
              _SheetButton(
                label: 'Cancel',
                tone: _Tone.neutral,
                onTap: () => Navigator.of(sheetCtx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'delete' && context.mounted) {
      final ok = await confirmDelete(context, title: title, kind: kind);
      if (ok) onDelete();
    }
  }
}

Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String kind,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Delete this $kind?',
        style: AppTextStyles.screenTitle(size: 18),
      ),
      content: Text(
        '"$title" will be removed permanently.',
        style: AppTextStyles.body(size: 13, color: AppColors.muted)
            .copyWith(height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancel',
            style: AppTextStyles.body(
              size: 14,
              color: AppColors.muted,
              weight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Delete',
            style: AppTextStyles.body(
              size: 14,
              color: const Color(0xFFB94A48),
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

enum _Tone { neutral, destructive }

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final _Tone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = tone == _Tone.destructive
        ? const Color(0xFFB94A48)
        : AppColors.ink;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 14,
              color: fg,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
