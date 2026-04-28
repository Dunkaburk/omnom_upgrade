import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF2A1F14);
  static const Color muted = Color(0xFF8C7B6E);
  static const Color border = Color(0xFFDDD2C4);
  static const Color cream = Color(0xFFFBF7F2);
  static const Color creamDark = Color(0xFFEDE5D8);
  static const Color white = Color(0xFFFFFFFF);

  static const Color defaultAccent = Color(0xFFC07B39);
}

extension HexColor on Color {
  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final padded = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    return Color(int.parse(padded, radix: 16));
  }
}
