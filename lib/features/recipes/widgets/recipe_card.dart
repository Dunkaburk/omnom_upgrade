import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/recipe.dart';
import '../../../providers/settings_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../utils/formatters.dart';

class RecipeCard extends ConsumerWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final totalTime = fmtTime(recipe.activeTime, recipe.passiveTime);
    final priceText = fmtPrice(recipe.price);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(photo: recipe.photo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: AppTextStyles.cardTitle().copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 5),
                      _MetaRow(
                        country: recipe.country,
                        servings: recipe.servings,
                        totalTime: totalTime,
                        priceText: priceText,
                        sourceIsUrl: recipe.source == 'url',
                        accent: accent,
                      ),
                      if (recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            for (final t in recipe.tags.take(3))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.creamDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  t,
                                  style: AppTextStyles.body(
                                    size: 11,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${recipe.ingredients.length} ing.',
                  style: AppTextStyles.small(size: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photo});
  final String? photo;

  @override
  Widget build(BuildContext context) {
    if (photo != null && photo!.isNotEmpty) {
      try {
        final bytes = _decodeDataUrl(photo!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {/* fall through */}
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text('📋', style: TextStyle(fontSize: 22)),
    );
  }

  Uint8List _decodeDataUrl(String s) {
    final comma = s.indexOf(',');
    final raw = comma >= 0 ? s.substring(comma + 1) : s;
    return base64Decode(raw);
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.country,
    required this.servings,
    required this.totalTime,
    required this.priceText,
    required this.sourceIsUrl,
    required this.accent,
  });

  final String country;
  final String servings;
  final String? totalTime;
  final String? priceText;
  final bool sourceIsUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (country.isNotEmpty) {
      children.add(Text('🌍 $country', style: AppTextStyles.small(size: 11)));
    }
    if (servings.isNotEmpty) {
      children.add(Text('· $servings srv', style: AppTextStyles.small(size: 11)));
    }
    if (totalTime != null) {
      children.add(Text('⏱ $totalTime', style: AppTextStyles.small(size: 11)));
    }
    if (priceText != null) {
      children.add(Text(priceText!, style: AppTextStyles.small(size: 11)));
    }
    if (sourceIsUrl) {
      children.add(Text('🔗', style: AppTextStyles.small(size: 11, color: accent)));
    }
    return Wrap(
      spacing: 5,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
