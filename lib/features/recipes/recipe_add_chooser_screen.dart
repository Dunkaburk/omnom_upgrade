import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../diary/widgets/omnom_back_button.dart';
import 'recipe_form_screen.dart';
import 'recipe_url_import_screen.dart';

class RecipeAddChooserScreen extends ConsumerWidget {
  const RecipeAddChooserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DecoratedBox(
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
                    Text(
                      'Add recipe',
                      style: AppTextStyles.screenTitle(size: 20)
                          .copyWith(height: 1.1),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          Text(
                            'How would you like to add it?',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.screenTitle(size: 17)
                                .copyWith(height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose a method below',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(
                              size: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OptionCard(
                      emoji: '✍️',
                      title: 'Add manually',
                      subtitle:
                          'Enter title, ingredients and details by hand',
                      accent: accent,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const RecipeFormScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _OptionCard(
                      emoji: '🔗',
                      title: 'Import from URL',
                      subtitle:
                          "Paste a link and we'll extract it automatically",
                      accent: accent,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const RecipeUrlImportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0x18 / 0xFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body(
                        size: 15,
                        color: AppColors.ink,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.body(
                        size: 12,
                        color: AppColors.muted,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '›',
                style: TextStyle(fontSize: 18, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
