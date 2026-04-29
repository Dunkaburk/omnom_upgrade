import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/text_field.dart';
import '../diary/widgets/omnom_back_button.dart';

/// Stub screen — the chooser routes here, but the actual import requires a
/// server-side scraper that does not yet exist. Renders the prototype's idle
/// hero with a disabled CTA so the navigation surface is correct for the
/// eventual Phase 4 wire-up.
class RecipeUrlImportScreen extends ConsumerStatefulWidget {
  const RecipeUrlImportScreen({super.key});

  @override
  ConsumerState<RecipeUrlImportScreen> createState() =>
      _RecipeUrlImportScreenState();
}

class _RecipeUrlImportScreenState
    extends ConsumerState<RecipeUrlImportScreen> {
  final _url = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Import from URL',
                            style: AppTextStyles.screenTitle(size: 20)
                                .copyWith(height: 1.1),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paste a recipe link',
                            style: AppTextStyles.small(size: 11),
                          ),
                        ],
                      ),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0x18 / 0xFF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🔗', style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Paste a recipe URL',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle(size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "We'll pull in the title, ingredients and description automatically.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        size: 13,
                        color: AppColors.muted,
                      ).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    OmnomTextField(
                      controller: _url,
                      placeholder: 'https://...',
                      keyboardType: TextInputType.url,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: null,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                'Import recipe',
                                style: AppTextStyles.body(
                                  size: 15,
                                  color: AppColors.muted,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coming soon — server-side scraping not yet available.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.small(size: 11).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
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
