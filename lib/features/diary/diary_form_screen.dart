import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/diary_entry.dart';
import '../../providers/diary_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../utils/id.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/pill.dart';
import '../../widgets/section_label.dart';
import '../../widgets/tag_input.dart';
import '../../widgets/text_field.dart';
import '../../widgets/time_cost_section.dart';
import 'widgets/omnom_back_button.dart';
import 'widgets/recipe_picker_sheet.dart';

class DiaryFormScreen extends ConsumerStatefulWidget {
  const DiaryFormScreen({super.key, this.initial});

  final DiaryEntry? initial;

  @override
  ConsumerState<DiaryFormScreen> createState() => _DiaryFormScreenState();
}

class _DiaryFormScreenState extends ConsumerState<DiaryFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _country;
  late final TextEditingController _activeTime;
  late final TextEditingController _passiveTime;
  late final TextEditingController _price;

  late String _date; // ISO YYYY-MM-DD
  late String _meal;
  late List<String> _tags;
  int? _r1;
  int? _r2;
  String? _photo;
  String? _linkedRecipeId;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _title = TextEditingController(text: i?.title ?? '');
    _title.addListener(() => setState(() {}));
    _desc = TextEditingController(text: i?.desc ?? '');
    _country = TextEditingController(text: i?.country ?? '');
    _activeTime = TextEditingController(
      text: i?.activeTime?.toString() ?? '',
    );
    _passiveTime = TextEditingController(
      text: i?.passiveTime?.toString() ?? '',
    );
    _price = TextEditingController(
      text: i?.price == null ? '' : _formatPriceInput(i!.price!),
    );

    _date = i?.date ?? DateTime.now().toIso8601String().substring(0, 10);
    _meal = i?.meal ?? '';
    _tags = [...?i?.tags];
    _r1 = i?.r1;
    _r2 = i?.r2;
    _photo = i?.photo;
    _linkedRecipeId = i?.linkedRecipeId;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _country.dispose();
    _activeTime.dispose();
    _passiveTime.dispose();
    _price.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty && !_saving;
  bool get _isEditing => widget.initial != null;

  String _formatPriceInput(double v) {
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
  }

  Future<void> _pickDate() async {
    DateTime current;
    try {
      current = DateTime.parse(_date);
    } catch (_) {
      current = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked.toIso8601String().substring(0, 10);
    });
  }

  Future<void> _pickRecipe() async {
    final id = await showRecipePickerSheet(
      context: context,
      selectedId: _linkedRecipeId,
    );
    if (id == null) return;
    setState(() => _linkedRecipeId = id);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final price = double.tryParse(_price.text.trim());
    final entry = DiaryEntry(
      id: widget.initial?.id ?? uid(),
      title: _title.text.trim(),
      desc: _desc.text.trim(),
      date: _date,
      meal: _meal,
      tags: List<String>.unmodifiable(_tags),
      r1: _r1,
      r2: _r2,
      activeTime: int.tryParse(_activeTime.text.trim()),
      passiveTime: int.tryParse(_passiveTime.text.trim()),
      price: price,
      photo: _photo,
      country: _country.text.trim().isEmpty ? null : _country.text.trim(),
      linkedRecipeId: _linkedRecipeId,
    );

    final notifier = ref.read(diaryEntriesProvider.notifier);
    if (_isEditing) {
      await notifier.updateEntry(entry);
    } else {
      await notifier.add(entry);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
    final people = ref.watch(peopleProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(isEditing: _isEditing, accent: accent),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildFormSections(accent: accent, people: people),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormSections({
    required Color accent,
    required ({String person1, String person2}) people,
  }) {
    return [
      _PhotoTitleRow(
        photo: _photo,
        titleController: _title,
        date: _date,
        onChangePhoto: (next) => setState(() => _photo = next),
        onPickDate: _pickDate,
      ),
      const SizedBox(height: 22),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Description'),
          OmnomTextField(
            controller: _desc,
            placeholder: 'How did it turn out? Any notes…',
            minLines: 3,
            maxLines: 6,
          ),
        ],
      ),
      const SizedBox(height: 22),
      _MealSection(
        meal: _meal,
        accent: accent,
        onChange: (m) => setState(() => _meal = m),
      ),
      const SizedBox(height: 22),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Country of origin', optional: true),
          OmnomTextField(
            controller: _country,
            placeholder: 'e.g. Italy, Japan, Morocco…',
          ),
        ],
      ),
      const SizedBox(height: 22),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Tags'),
          TagInput(
            tags: _tags,
            onChange: (next) => setState(() => _tags = next),
          ),
          const SizedBox(height: 5),
          Text(
            'Press Enter or comma to add',
            style: AppTextStyles.small(size: 11),
          ),
        ],
      ),
      const SizedBox(height: 22),
      TimeCostSection(
        activeController: _activeTime,
        passiveController: _passiveTime,
        priceController: _price,
      ),
      const SizedBox(height: 22),
      const Divider(height: 1, color: AppColors.border),
      const SizedBox(height: 22),
      _RatingsSection(
        r1: _r1,
        r2: _r2,
        people: people,
        accent: accent,
        onChange1: (v) => setState(() => _r1 = v),
        onChange2: (v) => setState(() => _r2 = v),
      ),
      const SizedBox(height: 22),
      _LinkedRecipeSection(
        linkedRecipeId: _linkedRecipeId,
        onTap: _pickRecipe,
        onClear: () => setState(() => _linkedRecipeId = null),
      ),
      const SizedBox(height: 22),
      _SaveButton(
        enabled: _canSave,
        accent: accent,
        label: _isEditing ? 'Save changes' : 'Save entry',
        onPressed: _save,
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isEditing, required this.accent});

  final bool isEditing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const OmnomBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit entry' : 'New entry',
                    style: AppTextStyles.screenTitle(size: 20)
                        .copyWith(height: 1.1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEditing
                        ? 'Update your notes and ratings'
                        : 'What did you make today?',
                    style: AppTextStyles.small(size: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'omnom',
              style: AppTextStyles.brandLogo(color: accent)
                  .copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sections
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoTitleRow extends StatelessWidget {
  const _PhotoTitleRow({
    required this.photo,
    required this.titleController,
    required this.date,
    required this.onChangePhoto,
    required this.onPickDate,
  });

  final String? photo;
  final TextEditingController titleController;
  final String date;
  final ValueChanged<String?> onChangePhoto;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoPicker(photo: photo, onChange: onChangePhoto),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              OmnomTextField(
                controller: titleController,
                placeholder: 'What did you make?',
              ),
              const SizedBox(height: 8),
              _DateField(date: date, onTap: onPickDate),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 8),
              Text(
                fmtDate(date),
                style: AppTextStyles.body(size: 14, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.meal,
    required this.accent,
    required this.onChange,
  });

  final String meal;
  final Color accent;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Meal type'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final m in kMealTypes)
              Pill(
                label: m,
                active: meal == m,
                accent: accent,
                onTap: () => onChange(meal == m ? '' : m),
              ),
          ],
        ),
      ],
    );
  }
}

class _RatingsSection extends StatelessWidget {
  const _RatingsSection({
    required this.r1,
    required this.r2,
    required this.people,
    required this.accent,
    required this.onChange1,
    required this.onChange2,
  });

  final int? r1;
  final int? r2;
  final ({String person1, String person2}) people;
  final Color accent;
  final ValueChanged<int?> onChange1;
  final ValueChanged<int?> onChange2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Ratings'),
        _RatingCard(
          name: people.person1,
          value: r1,
          accent: accent,
          onChange: onChange1,
        ),
        const SizedBox(height: 14),
        _RatingCard(
          name: people.person2,
          value: r2,
          accent: accent,
          onChange: onChange2,
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.name,
    required this.value,
    required this.accent,
    required this.onChange,
  });

  final String name;
  final int? value;
  final Color accent;
  final ValueChanged<int?> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.body(
                  size: 14,
                  color: AppColors.ink,
                  weight: FontWeight.w500,
                ),
              ),
              Text(
                value == null ? '—' : '$value/10',
                style: AppTextStyles.largeNumber(
                  size: 20,
                  color: value == null ? AppColors.muted : accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RatingPicker(
            value: value,
            accent: accent,
            onChange: onChange,
          ),
        ],
      ),
    );
  }
}

class _RatingPicker extends StatelessWidget {
  const _RatingPicker({
    required this.value,
    required this.accent,
    required this.onChange,
  });

  final int? value;
  final Color accent;
  final ValueChanged<int?> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 6,
      children: [
        for (var i = 1; i <= 10; i++)
          _RatingDot(
            number: i,
            selected: value == i,
            accent: accent,
            onTap: () => onChange(i),
          ),
      ],
    );
  }
}

class _RatingDot extends StatelessWidget {
  const _RatingDot({
    required this.number,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Material(
        color: selected ? accent : AppColors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? accent : AppColors.border,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTextStyles.body(
                size: 12,
                color: selected ? AppColors.white : AppColors.ink,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkedRecipeSection extends StatelessWidget {
  const _LinkedRecipeSection({
    required this.linkedRecipeId,
    required this.onTap,
    required this.onClear,
  });

  final String? linkedRecipeId;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasLink = linkedRecipeId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Linked recipe', optional: true),
        if (hasLink)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.creamDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text('📋', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Tap to change recipe',
                      style: AppTextStyles.body(
                        size: 14,
                        color: AppColors.ink,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                InkResponse(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          )
        else
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: AppColors.border,
                  radius: 12,
                  strokeWidth: 1.5,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.creamDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text('📋', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Link a recipe…',
                          style: AppTextStyles.body(
                            size: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.accent,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final Color accent;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? accent : AppColors.border;
    final fg = enabled ? AppColors.white : AppColors.muted;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0x44 / 0xFF),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.body(
                    size: 15,
                    color: fg,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
