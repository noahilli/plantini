import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class OrganicTokens {
  static const creamBackground = AppColors.bg;
  static const pageBackground = AppColors.neutral100;
  static const surface = AppColors.surface;
  static const ink = AppColors.ink;
  static const terracottaAction = AppColors.terracotta;
  static const sageSecondary = AppColors.sage;
  static const sageDark = AppColors.sage800;
  static const muted = AppColors.neutral700;
  static const radiusSmall = 8.0;
  static const radiusMedium = 16.0;
  static const radiusLarge = 28.0;
  static const radiusPill = 999.0;
  static final borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static final borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static final borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static final borderRadiusPill = BorderRadius.circular(radiusPill);
  static const pagePadding = EdgeInsets.symmetric(horizontal: 22, vertical: 10);
  static const softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x292E2B25), blurRadius: 10, offset: Offset(0, 3)),
  ];
}
