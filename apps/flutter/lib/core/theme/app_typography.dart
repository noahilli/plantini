import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const headingFamily = 'Caprasimo';
  static const bodyFamily = 'Figtree';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: headingFamily,
      fontSize: 42,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontFamily: headingFamily,
      fontSize: 32,
      height: 1.12,
    ),
    displaySmall: TextStyle(
      fontFamily: headingFamily,
      fontSize: 27,
      height: 1.1,
    ),
    headlineLarge: TextStyle(
      fontFamily: headingFamily,
      fontSize: 27,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontFamily: headingFamily,
      fontSize: 25,
      height: 1.12,
    ),
    headlineSmall: TextStyle(
      fontFamily: headingFamily,
      fontSize: 20,
      height: 1.12,
    ),
    titleLarge: TextStyle(
      fontFamily: headingFamily,
      fontSize: 19,
      height: 1.15,
    ),
    titleMedium: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w700,
    ),
    titleSmall: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(fontFamily: bodyFamily, fontSize: 16, height: 1.55),
    bodyMedium: TextStyle(fontFamily: bodyFamily, fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontFamily: bodyFamily, fontSize: 12, height: 1.45),
    labelLarge: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
    labelSmall: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    ),
  );
}
