import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_step.dart';
import '../../providers/recipe_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/id.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/section_label.dart';
import '../../widgets/tag_input.dart';
import '../../widgets/text_field.dart';
import '../../widgets/time_cost_section.dart';
import '../diary/widgets/omnom_back_button.dart';

class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({super.key, this.initial});

  final Recipe? initial;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _country;
  late final TextEditingController _servings;
  late final TextEditingController _activeTime;
  late final TextEditingController _passiveTime;
  late final TextEditingController _price;

  String? _photo;
  late List<String> _tags;
  late List<_IngredientDraft> _ingredients;
  late List<_StepDraft> _steps;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _title = TextEditingController(text: i?.title ?? '');
    _title.addListener(() => setState(() {}));
    _description = TextEditingController(text: i?.description ?? '');
    _country = TextEditingController(text: i?.country ?? '');
    _servings = TextEditingController(text: i?.servings ?? '');
    _activeTime = TextEditingController(text: i?.activeTime?.toString() ?? '');
    _passiveTime =
        TextEditingController(text: i?.passiveTime?.toString() ?? '');
    _price = TextEditingController(
      text: i?.price == null ? '' : _formatPriceInput(i!.price!),
    );

    _photo = i?.photo;
    _tags = [...?i?.tags];

    if (i != null && i.ingredients.isNotEmpty) {
      _ingredients = [for (final ing in i.ingredients) _IngredientDraft.from(ing)];
    } else {
      _ingredients = [_IngredientDraft.fresh()];
    }

    if (i != null && i.steps.isNotEmpty) {
      _steps = [for (final s in i.steps) _StepDraft.from(s)];
    } else {
      _steps = [_StepDraft.fresh()];
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _country.dispose();
    _servings.dispose();
    _activeTime.dispose();
    _passiveTime.dispose();
    _price.dispose();
    for (final ing in _ingredients) {
      ing.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty && !_saving;
  bool get _isEditing => widget.initial != null;

  String _formatPriceInput(double v) {
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
  }

  void _addIngredient() {
    setState(() => _ingredients.add(_IngredientDraft.fresh()));
  }

  void _removeIngredient(_IngredientDraft draft) {
    setState(() {
      _ingredients.remove(draft);
      draft.dispose();
      if (_ingredients.isEmpty) {
        _ingredients.add(_IngredientDraft.fresh());
      }
    });
  }

  void _addStep() {
    setState(() => _steps.add(_StepDraft.fresh()));
  }

  void _removeStep(_StepDraft draft) {
    setState(() {
      _steps.remove(draft);
      draft.dispose();
      if (_steps.isEmpty) {
        _steps.add(_StepDraft.fresh());
      }
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final ingredients = <Ingredient>[
      for (final draft in _ingredients)
        if (!draft.isEmpty) draft.toIngredient(),
    ];
    final steps = <RecipeStep>[
      for (final draft in _steps)
        if (draft.text.text.trim().isNotEmpty) draft.toStep(),
    ];

    final recipe = Recipe(
      id: widget.initial?.id ?? uid(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      servings: _servings.text.trim(),
      country: _country.text.trim(),
      tags: List<String>.unmodifiable(_tags),
      ingredients: List<Ingredient>.unmodifiable(ingredients),
      steps: List<RecipeStep>.unmodifiable(steps),
      activeTime: int.tryParse(_activeTime.text.trim()),
      passiveTime: int.tryParse(_passiveTime.text.trim()),
      price: double.tryParse(_price.text.trim()),
      photo: _photo,
      source: widget.initial?.source ?? 'manual',
      sourceUrl: widget.initial?.sourceUrl,
    );

    final notifier = ref.read(recipesProvider.notifier);
    if (_isEditing) {
      await notifier.updateEntry(recipe);
    } else {
      await notifier.add(recipe);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(isEditing: _isEditing),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildSections(accent: accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections({required Color accent}) {
    return [
      _PhotoTitleRow(
        photo: _photo,
        titleController: _title,
        countryController: _country,
        servingsController: _servings,
        onChangePhoto: (next) => setState(() => _photo = next),
      ),
      const SizedBox(height: 22),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Beskrivning', optional: true),
          OmnomTextField(
            controller: _description,
            placeholder: 'Vad gör det speciellt?',
            minLines: 2,
            maxLines: 6,
          ),
        ],
      ),
      const SizedBox(height: 22),
      _IngredientsSection(
        ingredients: _ingredients,
        onAdd: _addIngredient,
        onRemove: _removeIngredient,
      ),
      const SizedBox(height: 22),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Taggar'),
          TagInput(
            tags: _tags,
            onChange: (next) => setState(() => _tags = next),
          ),
          const SizedBox(height: 5),
          Text(
            'Tryck Enter eller komma för att lägga till',
            style: AppTextStyles.small(size: 11),
          ),
        ],
      ),
      const SizedBox(height: 22),
      _StepsSection(
        steps: _steps,
        onAdd: _addStep,
        onRemove: _removeStep,
      ),
      const SizedBox(height: 22),
      TimeCostSection(
        activeController: _activeTime,
        passiveController: _passiveTime,
        priceController: _price,
      ),
      const SizedBox(height: 22),
      _SaveButton(
        enabled: _canSave,
        accent: accent,
        label: _isEditing ? 'Spara ändringar' : 'Spara recept',
        onPressed: _save,
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isEditing});

  final bool isEditing;

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
          children: [
            const OmnomBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Redigera recept' : 'Lägg till recept',
                    style: AppTextStyles.screenTitle(size: 20)
                        .copyWith(height: 1.1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ange detaljerna nedan',
                    style: AppTextStyles.small(size: 11),
                  ),
                ],
              ),
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
    required this.countryController,
    required this.servingsController,
    required this.onChangePhoto,
  });

  final String? photo;
  final TextEditingController titleController;
  final TextEditingController countryController;
  final TextEditingController servingsController;
  final ValueChanged<String?> onChangePhoto;

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
                placeholder: 'Receptnamn',
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: OmnomTextField(
                      controller: countryController,
                      placeholder: 'Ursprungsland',
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: OmnomTextField(
                      controller: servingsController,
                      placeholder: '—',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      suffix: 'port.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection({
    required this.ingredients,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_IngredientDraft> ingredients;
  final VoidCallback onAdd;
  final ValueChanged<_IngredientDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INGREDIENSER', style: AppTextStyles.sectionLabel()),
              _SmallAddButton(label: '+ Lägg till', onTap: onAdd),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 26),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  'Antal',
                  style: AppTextStyles.body(
                    size: 10,
                    color: AppColors.muted,
                    weight: FontWeight.w500,
                  ).copyWith(letterSpacing: 0.07 * 10),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 60,
                child: Text(
                  'Enhet',
                  style: AppTextStyles.body(
                    size: 10,
                    color: AppColors.muted,
                    weight: FontWeight.w500,
                  ).copyWith(letterSpacing: 0.07 * 10),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ingrediens',
                  style: AppTextStyles.body(
                    size: 10,
                    color: AppColors.muted,
                    weight: FontWeight.w500,
                  ).copyWith(letterSpacing: 0.07 * 10),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            for (var i = 0; i < ingredients.length; i++) ...[
              if (i > 0) const SizedBox(height: 7),
              _IngredientRow(
                draft: ingredients[i],
                onRemove: () => onRemove(ingredients[i]),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.draft, required this.onRemove});

  final _IngredientDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52,
          child: OmnomTextField(
            controller: draft.qty,
            placeholder: '',
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          child: OmnomTextField(
            controller: draft.unit,
            placeholder: '',
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: OmnomTextField(
            controller: draft.name,
            placeholder: 'Ingrediens',
          ),
        ),
        SizedBox(
          width: 26,
          child: InkResponse(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 18, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({
    required this.steps,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_StepDraft> steps;
  final VoidCallback onAdd;
  final ValueChanged<_StepDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INSTRUKTIONER', style: AppTextStyles.sectionLabel()),
              _SmallAddButton(label: '+ Steg', onTap: onAdd),
            ],
          ),
        ),
        Column(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _StepRow(
                draft: steps[i],
                index: i,
                onRemove: () => onRemove(steps[i]),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.draft,
    required this.index,
    required this.onRemove,
  });

  final _StepDraft draft;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.creamDark,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.body(
                size: 11,
                color: AppColors.muted,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OmnomTextField(
            controller: draft.text,
            placeholder: 'Steg ${index + 1}…',
            minLines: 2,
            maxLines: 6,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: SizedBox(
            width: 24,
            child: InkResponse(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 18, color: AppColors.muted),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallAddButton extends StatelessWidget {
  const _SmallAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            label,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
          ),
        ),
      ),
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
// Drafts — each ingredient and step row owns its own controllers; the form
// disposes them.
// ─────────────────────────────────────────────────────────────────────────────

class _IngredientDraft {
  _IngredientDraft({
    required this.id,
    required this.qty,
    required this.unit,
    required this.name,
  });

  factory _IngredientDraft.fresh() => _IngredientDraft(
        id: uid(),
        qty: TextEditingController(),
        unit: TextEditingController(),
        name: TextEditingController(),
      );

  factory _IngredientDraft.from(Ingredient ing) => _IngredientDraft(
        id: ing.id,
        qty: TextEditingController(text: ing.qty),
        unit: TextEditingController(text: ing.unit),
        name: TextEditingController(text: ing.name),
      );

  final String id;
  final TextEditingController qty;
  final TextEditingController unit;
  final TextEditingController name;

  bool get isEmpty =>
      qty.text.trim().isEmpty &&
      unit.text.trim().isEmpty &&
      name.text.trim().isEmpty;

  Ingredient toIngredient() => Ingredient(
        id: id,
        qty: qty.text.trim(),
        unit: unit.text.trim(),
        name: name.text.trim(),
      );

  void dispose() {
    qty.dispose();
    unit.dispose();
    name.dispose();
  }
}

class _StepDraft {
  _StepDraft({required this.id, required this.text});

  factory _StepDraft.fresh() =>
      _StepDraft(id: uid(), text: TextEditingController());

  factory _StepDraft.from(RecipeStep s) =>
      _StepDraft(id: s.id, text: TextEditingController(text: s.text));

  final String id;
  final TextEditingController text;

  RecipeStep toStep() => RecipeStep(id: id, text: text.text.trim());

  void dispose() {
    text.dispose();
  }
}
