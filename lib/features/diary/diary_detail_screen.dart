import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/diary_entry.dart';
import '../../models/recipe.dart';
import '../../providers/app_tab_provider.dart';
import '../../providers/diary_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/section_label.dart';
import '../recipes/recipe_detail_screen.dart';
import '../shell/bottom_tab_bar.dart';
import 'diary_form_screen.dart';
import 'widgets/omnom_back_button.dart';

class DiaryDetailScreen extends ConsumerWidget {
  const DiaryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(diaryEntriesProvider).valueOrNull ?? const [];
    final entry = entries.cast<DiaryEntry?>().firstWhere(
          (e) => e?.id == entryId,
          orElse: () => null,
        );

    if (entry == null) {
      // Entry deleted underneath us — bounce back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: AppColors.cream);
    }

    final accent = ref.watch(accentColorProvider);
    final people = ref.watch(peopleProvider);
    final recipes = ref.watch(recipesProvider).valueOrNull ?? const [];
    final linked = entry.linkedRecipeId == null
        ? null
        : recipes.cast<Recipe?>().firstWhere(
              (r) => r?.id == entry.linkedRecipeId,
              orElse: () => null,
            );

    final avg = avgRating(entry.r1, entry.r2);

    void openLinkedRecipe() {
      if (linked == null) return;
      final navigator = Navigator.of(context);
      navigator.pop();
      ref.read(appTabStateProvider.notifier).set(AppTab.recipes);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => RecipeDetailScreen(recipeId: linked.id),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: entry.title,
              avg: avg,
              accent: accent,
              onBack: () => Navigator.maybePop(context),
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiaryFormScreen(initial: entry),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildBody(
                    entry: entry,
                    accent: accent,
                    people: people,
                    linked: linked,
                    onTapLinked: openLinkedRecipe,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody({
    required DiaryEntry entry,
    required Color accent,
    required ({String person1, String person2}) people,
    required Recipe? linked,
    required VoidCallback onTapLinked,
  }) {
    final sections = <Widget>[];

    void addSpacing() => sections.add(const SizedBox(height: 20));

    if (entry.photo != null && entry.photo!.isNotEmpty) {
      final bytes = _tryDecode(entry.photo!);
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
        addSpacing();
      }
    }

    sections.add(_MetadataPills(entry: entry, accent: accent));

    if (entry.desc.isNotEmpty) {
      addSpacing();
      sections.add(_NotesSection(text: entry.desc));
    }

    if ((entry.activeTime ?? 0) > 0 || (entry.passiveTime ?? 0) > 0) {
      addSpacing();
      sections.add(_TimeSection(
        activeTime: entry.activeTime,
        passiveTime: entry.passiveTime,
      ));
    }

    if (entry.tags.isNotEmpty) {
      addSpacing();
      sections.add(_TagsSection(tags: entry.tags));
    }

    if (entry.linkedRecipeId != null) {
      addSpacing();
      sections.add(
        _LinkedRecipeSection(linked: linked, onTap: onTapLinked),
      );
    }

    if (entry.r1 != null || entry.r2 != null) {
      addSpacing();
      sections.add(const Divider(height: 1, color: AppColors.border));
      addSpacing();
      sections.add(_RatingsSection(
        r1: entry.r1,
        r2: entry.r2,
        accent: accent,
        people: people,
      ));
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
    required this.avg,
    required this.accent,
    required this.onBack,
    required this.onEdit,
  });

  final String title;
  final String? avg;
  final Color accent;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OmnomBackButton(onPressed: onBack),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.screenTitle(size: 18).copyWith(height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (avg != null) ...[
              const SizedBox(width: 8),
              Text(
                avg!,
                style: AppTextStyles.largeNumber(size: 20, color: accent),
              ),
            ],
            const SizedBox(width: 8),
            _IconBtn(icon: Icons.edit_outlined, onPressed: onEdit),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _MetadataPills extends StatelessWidget {
  const _MetadataPills({required this.entry, required this.accent});

  final DiaryEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (entry.meal.isNotEmpty) {
      children.add(_MealBadge(label: entry.meal, accent: accent));
    }
    if (entry.date.isNotEmpty) {
      children.add(_NeutralPill(label: fmtDate(entry.date)));
    }
    final price = fmtPrice(entry.price);
    if (price != null) {
      children.add(_NeutralPill(label: price));
    }
    if (entry.country != null && entry.country!.isNotEmpty) {
      children.add(_NeutralPill(label: '🌍 ${entry.country}'));
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: children,
    );
  }
}

class _MealBadge extends StatelessWidget {
  const _MealBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0x1A / 0xFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 12,
          color: accent,
          weight: FontWeight.w500,
        ),
      ),
    );
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

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Anteckningar'),
        Text(
          text,
          style: AppTextStyles.body(size: 14, color: AppColors.ink)
              .copyWith(height: 1.65),
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

class _TagsSection extends StatelessWidget {
  const _TagsSection({required this.tags});

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

class _LinkedRecipeSection extends StatelessWidget {
  const _LinkedRecipeSection({required this.linked, required this.onTap});

  final Recipe? linked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = linked?.title ?? 'Länkat recept';
    final subtitleParts = <String>[
      if ((linked?.country ?? '').isNotEmpty) linked!.country,
      if ((linked?.ingredients.length ?? 0) > 0)
        '${linked!.ingredients.length} ingredienser',
    ];
    final subtitle = subtitleParts.join(' · ');
    final tappable = linked != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Länkat recept'),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: tappable ? onTap : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.creamDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text('📋', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.cardTitle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(subtitle, style: AppTextStyles.small(size: 11)),
                        ],
                      ],
                    ),
                  ),
                  if (tappable)
                    const Text(
                      '›',
                      style:
                          TextStyle(fontSize: 18, color: AppColors.muted),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingsSection extends StatelessWidget {
  const _RatingsSection({
    required this.r1,
    required this.r2,
    required this.accent,
    required this.people,
  });

  final int? r1;
  final int? r2;
  final Color accent;
  final ({String person1, String person2}) people;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];
    if (r1 != null) {
      cards.add(Expanded(
        child: _RatingCard(name: people.person1, value: r1!, accent: accent),
      ));
    }
    if (r2 != null) {
      if (cards.isNotEmpty) cards.add(const SizedBox(width: 12));
      cards.add(Expanded(
        child: _RatingCard(name: people.person2, value: r2!, accent: accent),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Betyg'),
        Row(children: cards),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.name,
    required this.value,
    required this.accent,
  });

  final String name;
  final int value;
  final Color accent;

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
          Text(name, style: AppTextStyles.body(size: 12, color: AppColors.muted)),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: AppTextStyles.largeNumber(size: 28, color: accent),
          ),
          Text('av 10', style: AppTextStyles.small(size: 11)),
        ],
      ),
    );
  }
}
