import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Small pill button that toggles a list into "edit mode". Shows a pencil
/// icon by default; flips to "Done" with the accent treatment when active.
class EditModeButton extends StatelessWidget {
  const EditModeButton({
    super.key,
    required this.editing,
    required this.accent,
    required this.onTap,
  });

  final bool editing;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = editing ? accent : AppColors.muted;
    final bg = editing
        ? accent.withValues(alpha: 0x18 / 0xFF)
        : AppColors.creamDark;
    final borderColor = editing
        ? accent.withValues(alpha: 0x44 / 0xFF)
        : AppColors.border;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Semantics(
          button: true,
          label: editing ? 'Klar med redigering' : 'Redigera lista',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: editing
                ? Text(
                    'Klar',
                    style: AppTextStyles.body(
                      size: 12,
                      color: fg,
                      weight: FontWeight.w500,
                    ),
                  )
                : Icon(Icons.edit_outlined, size: 16, color: fg),
          ),
        ),
      ),
    );
  }
}

/// Round red trash button shown next to each card when the list is in
/// edit mode. Tapping triggers the caller's confirm + delete flow.
class TrashButton extends StatelessWidget {
  const TrashButton({super.key, required this.onTap, this.itemTitle});

  final VoidCallback onTap;
  final String? itemTitle;

  static const Color destructive = Color(0xFFB94A48);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: destructive.withValues(alpha: 0x18 / 0xFF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Semantics(
          button: true,
          label: itemTitle == null ? 'Ta bort' : 'Ta bort $itemTitle',
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: destructive.withValues(alpha: 0x44 / 0xFF),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.delete_outline,
              size: 18,
              color: destructive,
            ),
          ),
        ),
      ),
    );
  }
}
