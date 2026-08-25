import 'package:flutter/material.dart';

/// Design System v2 Color Palette for Plantini
/// Matches the official Plantini App Design specification (WCAG 2.2 AA compliant).
class AppColors {
  static const Color forest = Color(0xFF2F5D50);
  static const Color forestDark = Color(0xFF21473D);
  static const Color sage = Color(0xFF6D8B74);
  static const Color moss = Color(0xFF98A886);
  static const Color cream = Color(0xFFF7F4EC);
  static const Color beige = Color(0xFFE8E0D0);
  static const Color sand = Color(0xFFD9C7A3);
  static const Color bark = Color(0xFF7A563A);
  static const Color ink = Color(0xFF26332F);
  static const Color muted = Color(0xFF65716C);
  static const Color line = Color(0xFFD9DED9);
  static const Color white = Colors.white;
  static const Color mint = Color(0xFFDDECDA);
  static const Color sun = Color(0xFFF1DF9B);
  static const Color danger = Color(0xFFA35D49);
  static const Color warningBg = Color(0xFFFFF5E8);
  static const Color warningBorder = Color(0xFFF0D8B8);

  // Semantic mappings
  static const Color primary = forest;
  static const Color onPrimary = white;
  static const Color secondary = sage;
  static const Color onSecondary = white;
  static const Color background = cream;
  static const Color onBackground = ink;
  static const Color surface = white;
  static const Color onSurface = ink;
  static const Color error = danger;
  static const Color onError = white;
  static const Color success = forest;
}
