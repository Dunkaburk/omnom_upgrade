import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/diary_entry.dart';
import '../../../providers/settings_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../utils/formatters.dart';

class DiaryCard extends ConsumerWidget {
  const DiaryCard({super.key, required this.entry, required this.onTap});

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final people = ref.watch(peopleProvider);

    final avgR = avgRating(entry.r1, entry.r2);
    final totalTime = fmtTime(entry.activeTime, entry.passiveTime);
    final priceText = fmtPrice(entry.price);
    final dateStr = fmtDate(entry.date);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000), // ~6% opacity
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
                _Thumbnail(photo: entry.photo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleRow(title: entry.title, avg: avgR, accent: accent),
                      const SizedBox(height: 6),
                      _PillRow(
                        meal: entry.meal,
                        country: entry.country,
                        totalTime: totalTime,
                        priceText: priceText,
                        accent: accent,
                      ),
                      const SizedBox(height: 7),
                      _BottomRow(
                        person1: people.person1,
                        person2: people.person2,
                        r1: entry.r1,
                        r2: entry.r2,
                        date: dateStr,
                        accent: accent,
                      ),
                    ],
                  ),
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
      } catch (_) {/* fall through to placeholder */}
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text('🍽️', style: TextStyle(fontSize: 20)),
    );
  }

  Uint8List _decodeDataUrl(String s) {
    final comma = s.indexOf(',');
    final raw = comma >= 0 ? s.substring(comma + 1) : s;
    return base64Decode(raw);
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.avg, required this.accent});
  final String title;
  final String? avg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.cardTitle().copyWith(height: 1.3),
          ),
        ),
        if (avg != null) ...[
          const SizedBox(width: 8),
          Text(
            avg!,
            style: AppTextStyles.largeNumber(size: 15, color: accent),
          ),
        ],
      ],
    );
  }
}

class _PillRow extends StatelessWidget {
  const _PillRow({
    required this.meal,
    required this.country,
    required this.totalTime,
    required this.priceText,
    required this.accent,
  });

  final String meal;
  final String? country;
  final String? totalTime;
  final String? priceText;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (meal.isNotEmpty) {
      children.add(_MealPill(label: meal, accent: accent));
    }
    if (country != null && country!.isNotEmpty) {
      children.add(_TextPill(label: '🌍 $country'));
    }
    if (totalTime != null) {
      children.add(_TextPill(label: '⏱ $totalTime'));
    }
    if (priceText != null) {
      children.add(_TextPill(label: priceText!));
    }

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _MealPill extends StatelessWidget {
  const _MealPill({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0x1A / 0xFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 11,
          color: accent,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TextPill extends StatelessWidget {
  const _TextPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.small(size: 11));
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.person1,
    required this.person2,
    required this.r1,
    required this.r2,
    required this.date,
    required this.accent,
  });

  final String person1;
  final String person2;
  final int? r1;
  final int? r2;
  final String date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: 10,
          children: [
            if (r1 != null)
              _PersonRating(name: person1, rating: r1!, accent: accent),
            if (r2 != null)
              _PersonRating(name: person2, rating: r2!, accent: accent),
          ],
        ),
        Text(date, style: AppTextStyles.small(size: 11)),
      ],
    );
  }
}

class _PersonRating extends StatelessWidget {
  const _PersonRating({
    required this.name,
    required this.rating,
    required this.accent,
  });
  final String name;
  final int rating;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.small(size: 11),
        children: [
          TextSpan(
            text: name,
            style: AppTextStyles.small(
              size: 11,
              color: AppColors.ink,
              weight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: '$rating',
            style: AppTextStyles.small(
              size: 11,
              color: accent,
              weight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: '/10'),
        ],
      ),
    );
  }
}
