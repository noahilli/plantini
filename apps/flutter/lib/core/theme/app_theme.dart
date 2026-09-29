import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: Brightness.light,
      primary: AppColors.terracotta,
      secondary: AppColors.sage,
      surface: AppColors.neutral100,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: AppTypography.bodyFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.neutral100,
      dividerColor: AppColors.divider,
      splashColor: AppColors.accent200.withValues(alpha: .45),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutral100,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: AppColors.sage300.withValues(alpha: .5)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.bg,
          minimumSize: const Size(52, 52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: AppTypography.headingFamily,
            fontSize: 14,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.bg,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: AppTypography.headingFamily,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.divider),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: AppColors.neutral100,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.sage200,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppTypography.bodyFamily,
            fontSize: 10,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent700
                : AppColors.neutral600,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.terracotta,
        linearTrackColor: AppColors.neutral300,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sage200,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(
          color: AppColors.sage800,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
