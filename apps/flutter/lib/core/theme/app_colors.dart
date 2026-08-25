import 'package:flutter/material.dart';

/// Central color definitions for the Plantini app.
/// Selected to ensure WCAG 2.2 AA compliance for contrast ratios.
class AppColors {
  // Primary: A deep green for high contrast against white/light backgrounds.
  static const Color primary = Color(0xFF1B5E20); // Green 900
  static const Color onPrimary = Colors.white;

  // Secondary: A distinct color (e.g., Earthy brown/orange) for accents.
  static const Color secondary = Color(0xFFE65100); // Orange 900
  static const Color onSecondary = Colors.white;

  // Background and Surface
  static const Color background = Color(0xFFF1F8E9); // Light Green 50
  static const Color onBackground = Color(0xFF1B1B1B);

  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF1B1B1B);

  // Semantic Colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Colors.white;

  static const Color success = Color(0xFF00796B); // Teal 700

  // Dark Mode variations
  static const Color primaryDark = Color(0xFF81C784); // Green 300
  static const Color onPrimaryDark = Color(0xFF000000);

  static const Color secondaryDark = Color(0xFFFFB74D); // Orange 300
  static const Color onSecondaryDark = Color(0xFF000000);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onBackgroundDark = Colors.white;
  static const Color onSurfaceDark = Colors.white;

  static const Color errorDark = Color(0xFFCF6679);
}
