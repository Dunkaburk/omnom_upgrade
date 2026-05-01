import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Free-form tag input: bordered container with chips + an inline text field
/// that adds the trimmed value on Enter or comma. Mirrors the prototype's
/// `<TagInput/>`.
class TagInput extends StatefulWidget {
  const TagInput({super.key, required this.tags, required this.onChange});

  final List<String> tags;
  final ValueChanged<List<String>> onChange;

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final value = raw.replaceAll(',', '').trim();
    if (value.isEmpty) {
      _input.clear();
      return;
    }
    if (widget.tags.contains(value)) {
      _input.clear();
      return;
    }
    widget.onChange([...widget.tags, value]);
    _input.clear();
  }

  void _remove(String tag) {
    widget.onChange(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final t in widget.tags)
            _TagChip(label: t, onRemove: () => _remove(t)),
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80),
              child: TextField(
                controller: _input,
                focusNode: _focus,
                style: AppTextStyles.body(size: 13, color: AppColors.ink),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  border: InputBorder.none,
                  hintText: widget.tags.isEmpty ? 'Lägg till en tagg' : '',
                  hintStyle: AppTextStyles.body(size: 13, color: AppColors.muted),
                ),
                inputFormatters: [_CommaTagFormatter(_commit)],
                onSubmitted: (v) {
                  _commit(v);
                  _focus.requestFocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommaTagFormatter extends TextInputFormatter {
  _CommaTagFormatter(this.onComma);
  final ValueChanged<String> onComma;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains(',')) {
      onComma(newValue.text);
      return const TextEditingValue();
    }
    return newValue;
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 4, 6, 4),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.body(size: 12, color: AppColors.ink),
          ),
          const SizedBox(width: 4),
          InkResponse(
            onTap: onRemove,
            radius: 12,
            child: const Icon(Icons.close, size: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
