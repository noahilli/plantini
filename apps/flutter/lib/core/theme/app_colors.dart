import 'package:flutter/material.dart';

/// Organic Plantini palette, transcribed from `ds/organic.css`.
abstract final class AppColors {
  static const bg = Color(0xFFF5EAD8);
  static const surface = Color(0xFFEBDDC5);
  static const ink = Color(0xFF201E1D);
  static const terracotta = Color(0xFFC67139);
  static const sage = Color(0xFF7A8A5E);
  static const neutral100 = Color(0xFFF9F4ED);
  static const neutral200 = Color(0xFFEEE7DB);
  static const neutral300 = Color(0xFFDCD3C4);
  static const neutral400 = Color(0xFFC0B6A5);
  static const neutral500 = Color(0xFFA19786);
  static const neutral600 = Color(0xFF82796A);
  static const neutral700 = Color(0xFF645C50);
  static const neutral800 = Color(0xFF474238);
  static const neutral900 = Color(0xFF2E2B25);
  static const accent100 = Color(0xFFFFF2EB);
  static const accent200 = Color(0xFFFFE1D0);
  static const accent300 = Color(0xFFFFC6A5);
  static const accent400 = Color(0xFFF6A06B);
  static const accent500 = Color(0xFFD67F48);
  static const accent600 = Color(0xFFB2622D);
  static const accent700 = Color(0xFF8C491A);
  static const accent800 = Color(0xFF643312);
  static const accent900 = Color(0xFF402310);
  static const sage100 = Color(0xFFF0FAE1);
  static const sage200 = Color(0xFFE1EECC);
  static const sage300 = Color(0xFFCCDBB2);
  static const sage400 = Color(0xFFAEBF92);
  static const sage500 = Color(0xFF8FA073);
  static const sage600 = Color(0xFF728157);
  static const sage700 = Color(0xFF56633F);
  static const sage800 = Color(0xFF3D472B);
  static const sage900 = Color(0xFF272E1B);
  static const divider = Color(0x29201E1D);
  static const danger = accent700;

  // Compatibility names used by existing domain widgets.
  static const forest = sage800;
  static const forestDark = sage900;
  static const moss = sage400;
  static const cream = neutral100;
  static const beige = surface;
  static const sand = neutral400;
  static const bark = accent800;
  static const muted = neutral700;
  static const line = divider;
  static const white = neutral100;
  static const mint = sage200;
  static const sun = accent300;
  static const warningBg = accent100;
  static const warningBorder = accent300;
  static const primary = terracotta;
  static const onPrimary = bg;
  static const secondary = sage;
  static const onSecondary = neutral100;
  static const background = bg;
  static const onBackground = ink;
  static const onSurface = ink;
  static const error = danger;
  static const onError = neutral100;
  static const success = sage600;
}
