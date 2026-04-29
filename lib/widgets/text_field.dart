import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Shared text field matching the prototype's <Field/> shape: white bg,
/// 1.5px border, 12px radius, 9–10px vertical padding, DM Sans 14 ink.
class OmnomTextField extends StatelessWidget {
  const OmnomTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.textAlign = TextAlign.start,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String placeholder;
  final int? minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? suffix;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      style: AppTextStyles.body(size: 14, color: AppColors.ink),
      cursorColor: AppColors.ink,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: contentPadding ??
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
