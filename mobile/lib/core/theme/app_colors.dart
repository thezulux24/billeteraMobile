import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF0A7B83);
  static const Color accent = Color(0xFFF4A63A);

  static const Color lightBackgroundTop = Color(0xFFEFF9FB);
  static const Color lightBackgroundBottom = Color(0xFFD7ECF2);
  static const Color darkBackgroundTop = Color(0xFF081E27);
  static const Color darkBackgroundBottom = Color(0xFF061117);

  static const Color orbCyan = Color(0xFF43D2E2);
  static const Color orbBlue = Color(0xFF3F89FF);
  static const Color orbGold = Color(0xFFF2B24A);
  static const Color orbPink = Color(0xFFFF8BA7);

  static const Color stitchIndigo = Color(0xFF4F46E5);
  static const Color stitchPurple = Color(0xFF7C3AED);
  static const Color stitchDarkBackground = Color(0xFF0F0E1C);

  static const Color glassLight = Color(0x7AFFFFFF);
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassBorderLight = Color(0xA6FFFFFF);
  static const Color glassBorderDark = Color(0x26FFFFFF);

  // Semantic glass colors
  static Color glassBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.black.withValues(alpha: 0.05);

  static Color glassBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.15)
      : Colors.black.withValues(alpha: 0.1);

  static Color glassLabel(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xffa5b4fc)
      : const Color(0xff4f46e5).withValues(alpha: 0.7);
}
