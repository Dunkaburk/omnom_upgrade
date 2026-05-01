import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_step.dart';
import '../../providers/recipe_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/section_label.dart';
import '../diary/widgets/omnom_back_button.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).valueOrNull ?? const [];
    final recipe = recipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == recipeId,
          orElse: () => null,
        );

    if (recipe == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: AppColors.cream);
    }

    final accent = ref.watch(accentColorProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: recipe.title,
              onBack: () => Navigator.maybePop(context),
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecipeFormScreen(initial: recipe),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildBody(recipe: recipe, accent: accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody({required Recipe recipe, required Color accent}) {
    final sections = <Widget>[];
    void gap() => sections.add(const SizedBox(height: 20));

    if (recipe.photo != null && recipe.photo!.isNotEmpty) {
      final bytes = _tryDecode(recipe.photo!);
      if (bytes != null) {
        sections.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        );
        gap();
      }
    }

    sections.add(_MetadataPills(recipe: recipe, accent: accent));

    if (recipe.description.isNotEmpty) {
      gap();
      sections.add(_About(text: recipe.description));
    }

    if (recipe.ingredients.isNotEmpty) {
      gap();
      sections.add(_IngredientsCard(ingredients: recipe.ingredients));
    }

    if (recipe.steps.isNotEmpty) {
      gap();
      sections.add(_StepsList(steps: recipe.steps, accent: accent));
    }

    if ((recipe.activeTime ?? 0) > 0 || (recipe.passiveTime ?? 0) > 0) {
      gap();
      sections.add(_TimeSection(
        activeTime: recipe.activeTime,
        passiveTime: recipe.passiveTime,
      ));
    }

    if (recipe.tags.isNotEmpty) {
      gap();
      sections.add(_TagsRow(tags: recipe.tags));
    }

    if (recipe.price != null) {
      gap();
      sections.add(const Divider(height: 1, color: AppColors.border));
      sections.add(const SizedBox(height: 16));
      sections.add(_CostSection(price: recipe.price!));
    }

    if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty) {
      gap();
      sections.add(_SourceBlock(url: recipe.sourceUrl!, accent: accent));
    }

    return sections;
  }
}

Uint8List? _tryDecode(String dataUrl) {
  try {
    final comma = dataUrl.indexOf(',');
    final raw = comma >= 0 ? dataUrl.substring(comma + 1) : dataUrl;
    return base64Decode(raw);
  } catch (_) {
    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onBack,
    required this.onEdit,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onEdit;

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
            OmnomBackButton(onPressed: onBack),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.screenTitle(size: 18)
                    .copyWith(height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 34,
              height: 34,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onEdit,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataPills extends StatelessWidget {
  const _MetadataPills({required this.recipe, required this.accent});

  final Recipe recipe;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (recipe.country.isNotEmpty) {
      children.add(_NeutralPill(label: '🌍 ${recipe.country}'));
    }
    if (recipe.servings.isNotEmpty) {
      children.add(_NeutralPill(label: '${recipe.servings} port.'));
    }
    final price = fmtPrice(recipe.price);
    if (price != null) {
      children.add(_NeutralPill(label: price));
    }
    final total = fmtTime(recipe.activeTime, recipe.passiveTime);
    if (total != null) {
      children.add(_NeutralPill(label: '⏱ $total'));
    }
    if (recipe.source == 'url') {
      children.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0x1A / 0xFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '🔗 Importerad',
            style: AppTextStyles.body(
              size: 12,
              color: accent,
              weight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Wrap(spacing: 7, runSpacing: 7, children: children);
  }
}

class _NeutralPill extends StatelessWidget {
  const _NeutralPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(size: 12, color: AppColors.muted),
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Om'),
        Text(
          text,
          style: AppTextStyles.body(size: 14, color: AppColors.ink)
              .copyWith(height: 1.65),
        ),
      ],
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  const _IngredientsCard({required this.ingredients});
  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Ingredienser'),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              children: [
                for (var i = 0; i < ingredients.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                      thickness: 1,
                    ),
                  _IngredientLine(ingredient: ingredients[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientLine extends StatelessWidget {
  const _IngredientLine({required this.ingredient});
  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final left = [
      ingredient.qty,
      if (ingredient.unit.isNotEmpty) ingredient.unit,
    ].where((s) => s.isNotEmpty).join(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              left,
              style: AppTextStyles.body(size: 13, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ingredient.name,
              style: AppTextStyles.body(size: 14, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  const _StepsList({required this.steps, required this.accent});

  final List<RecipeStep> steps;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Instruktioner'),
        Column(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _StepLine(index: i, step: steps[i], accent: accent),
            ],
          ],
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({
    required this.index,
    required this.step,
    required this.accent,
  });

  final int index;
  final RecipeStep step;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0x18 / 0xFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0x33 / 0xFF),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.body(
                size: 12,
                color: accent,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              step.text,
              style: AppTextStyles.body(size: 14, color: AppColors.ink)
                  .copyWith(height: 1.65),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({required this.activeTime, required this.passiveTime});

  final int? activeTime;
  final int? passiveTime;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];
    if ((activeTime ?? 0) > 0) {
      cards.add(Expanded(
        child: _TimeCard(label: 'Aktiv', value: fmtTime(activeTime, 0) ?? '—'),
      ));
    }
    if ((passiveTime ?? 0) > 0) {
      if (cards.isNotEmpty) cards.add(const SizedBox(width: 12));
      cards.add(Expanded(
        child: _TimeCard(label: 'Passiv', value: fmtTime(0, passiveTime) ?? '—'),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Tid'),
        Row(children: cards),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.small(size: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.largeNumber(size: 18, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Taggar'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final t in tags)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.creamDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t,
                  style: AppTextStyles.body(size: 12, color: AppColors.ink),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CostSection extends StatelessWidget {
  const _CostSection({required this.price});
  final double price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Kostnad'),
        Text(
          fmtPrice(price) ?? '',
          style: AppTextStyles.largeNumber(size: 20, color: AppColors.ink),
        ),
      ],
    );
  }
}

class _SourceBlock extends StatelessWidget {
  const _SourceBlock({required this.url, required this.accent});
  final String url;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0x10 / 0xFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0x22 / 0xFF),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Källa',
            style: AppTextStyles.body(
              size: 11,
              color: accent,
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            url,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
