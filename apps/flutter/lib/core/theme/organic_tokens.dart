import 'package:flutter/material.dart';

/// Design tokens for the Organic Theme.
/// Contains colors, radii, and other styling constants.
abstract class OrganicTokens {
  // Colors
  static const Color creamBackground = Color(0xFFF5EAD8);
  static const Color terracottaAction = Color(0xFFC67139);
  static const Color sageSecondary = Color(0xFF7A8A5E);

  // Radii
  static const double radiusSmall = 20.0;
  static const double radiusLarge = 28.0;

  // Border Radii
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(
    radiusSmall,
  );
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(
    radiusLarge,
  );
}
