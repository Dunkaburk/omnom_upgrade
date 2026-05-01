import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'section_label.dart';
import 'text_field.dart';

/// Active+passive time row plus the cost field, used by both the diary form
/// and the recipe form. Caller owns the controllers.
class TimeCostSection extends StatelessWidget {
  const TimeCostSection({
    super.key,
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
        const SectionLabel('Tid & kostnad', optional: true),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MinuteField(
                label: 'Aktiv tid',
                controller: activeController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MinuteField(
                label: 'Passiv tid',
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
                'Uppskattad kostnad',
                style: AppTextStyles.body(size: 12, color: AppColors.muted),
              ),
            ),
            OmnomTextField(
              controller: priceController,
              placeholder: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: 'kr',
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
        OmnomTextField(
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
