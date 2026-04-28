import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/diary_entry.dart';
import '../../providers/diary_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../utils/id.dart';
import '../../widgets/pill.dart';
import '../../widgets/section_label.dart';
import 'widgets/omnom_back_button.dart';

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

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final f = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (f == null) return;
      final bytes = await f.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photo = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });
    } catch (_) {
      // Permission denied or unsupported on this platform — ignore silently.
    }
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
        onPickPhoto: _pickPhoto,
        onPickDate: _pickDate,
      ),
      const SizedBox(height: 22),
      _DescriptionSection(controller: _desc),
      const SizedBox(height: 22),
      _MealSection(
        meal: _meal,
        accent: accent,
        onChange: (m) => setState(() => _meal = m),
      ),
      const SizedBox(height: 22),
      _CountrySection(controller: _country),
      const SizedBox(height: 22),
      _TagsSection(
        tags: _tags,
        onChange: (next) => setState(() => _tags = next),
      ),
      const SizedBox(height: 22),
      _TimeAndCostSection(
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
            Text('omnom', style: AppTextStyles.brandLogo(color: accent).copyWith(fontSize: 20)),
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
    required this.onPickPhoto,
    required this.onPickDate,
  });

  final String? photo;
  final TextEditingController titleController;
  final String date;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhotoPicker(photo: photo, onTap: onPickPhoto),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              _Field(
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

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photo, required this.onTap});

  final String? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null && photo!.isNotEmpty;
    Uint8List? bytes;
    if (hasPhoto) {
      try {
        final s = photo!;
        final comma = s.indexOf(',');
        bytes = base64Decode(comma >= 0 ? s.substring(comma + 1) : s);
      } catch (_) {/* ignore */}
    }
    return SizedBox(
      width: 78,
      height: 78,
      child: Material(
        color: hasPhoto ? Colors.transparent : AppColors.creamDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    bytes,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                )
              : CustomPaint(
                  painter: _DashedBorderPainter(
                    color: AppColors.border,
                    radius: 14,
                    strokeWidth: 2,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📷', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 2),
                        Text(
                          'Add\nphoto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.3,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  static const double _dashLength = 5;
  static const double _gapLength = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + _dashLength;
        dashed.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + _gapLength;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      strokeWidth != oldDelegate.strokeWidth;
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

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Description'),
        _Field(
          controller: controller,
          placeholder: 'How did it turn out? Any notes…',
          minLines: 3,
          maxLines: 6,
        ),
      ],
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

class _CountrySection extends StatelessWidget {
  const _CountrySection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Country of origin', optional: true),
        _Field(
          controller: controller,
          placeholder: 'e.g. Italy, Japan, Morocco…',
        ),
      ],
    );
  }
}

class _TagsSection extends StatefulWidget {
  const _TagsSection({required this.tags, required this.onChange});

  final List<String> tags;
  final ValueChanged<List<String>> onChange;

  @override
  State<_TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<_TagsSection> {
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
    if (value.isEmpty) return;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Tags'),
        Container(
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
              for (final t in widget.tags) _TagChip(label: t, onRemove: () => _remove(t)),
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
                      hintText: widget.tags.isEmpty ? 'Add a tag' : '',
                      hintStyle: AppTextStyles.body(size: 13, color: AppColors.muted),
                    ),
                    inputFormatters: [
                      _CommaTagFormatter(_commit),
                    ],
                    onSubmitted: (v) {
                      _commit(v);
                      _focus.requestFocus();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Press Enter or comma to add',
          style: AppTextStyles.small(size: 11),
        ),
      ],
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
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeAndCostSection extends StatelessWidget {
  const _TimeAndCostSection({
    required this.activeController,
    required this.passiveController,
    required this.priceController,
  });

  final TextEditingController activeController;
  final TextEditingController passiveController;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Time & cost', optional: true),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MinuteField(
                label: 'Active time',
                controller: activeController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MinuteField(
                label: 'Passive time',
                controller: passiveController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                'Estimated cost',
                style: AppTextStyles.body(size: 12, color: AppColors.muted),
              ),
            ),
            _Field(
              controller: priceController,
              placeholder: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: '£',
            ),
          ],
        ),
      ],
    );
  }
}

class _MinuteField extends StatelessWidget {
  const _MinuteField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            label,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
          ),
        ),
        _Field(
          controller: controller,
          placeholder: '—',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          suffix: 'min',
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
    required this.onClear,
  });

  final String? linkedRecipeId;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Linked recipe', optional: true),
        if (linkedRecipeId != null)
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
                  child: Text(
                    'Linked recipe',
                    style: AppTextStyles.body(
                      size: 14,
                      color: AppColors.ink,
                      weight: FontWeight.w500,
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
          CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.border,
              radius: 12,
              strokeWidth: 1.5,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      'Link a recipe… (coming soon)',
                      style: AppTextStyles.body(size: 14, color: AppColors.muted),
                    ),
                  ),
                ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Field — shared text input matching the prototype's <Field/> + numeric variant.
// ─────────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.placeholder,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final String placeholder;
  final int? minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTextStyles.body(size: 14, color: AppColors.ink),
      cursorColor: AppColors.ink,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintText: placeholder,
        hintStyle: AppTextStyles.body(size: 14, color: AppColors.muted),
        prefixText: prefix,
        prefixStyle: AppTextStyles.body(size: 14, color: AppColors.muted),
        suffixText: suffix,
        suffixStyle: AppTextStyles.body(size: 12, color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.muted, width: 1.5),
        ),
      ),
    );
  }
}
