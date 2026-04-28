import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Brand "omnom" logotype — Playfair italic 700 / 26px / accent-coloured at use site.
  static TextStyle brandLogo({Color? color}) => GoogleFonts.playfairDisplay(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.0,
        color: color,
      );

  // Top-of-screen titles like "Recipes", "Discover" — Playfair 500.
  static TextStyle screenTitle({double size = 22, Color color = AppColors.ink}) =>
      GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.w500,
        fontSize: size,
        color: color,
      );

  // List card title — Playfair 500 15px.
  static TextStyle cardTitle({Color color = AppColors.ink}) =>
      GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: color,
      );

  // Avg rating / large numbers — Playfair 700.
  static TextStyle largeNumber({double size = 20, Color color = AppColors.ink}) =>
      GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
      );

  // Body / labels.
  static TextStyle body({double size = 13, Color color = AppColors.ink, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // Small metadata.
  static TextStyle small({double size = 11, Color color = AppColors.muted, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // ALL CAPS section labels.
  static TextStyle sectionLabel({Color color = AppColors.muted}) =>
      GoogleFonts.dmSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1 * 10.5,
        color: color,
      );
}
