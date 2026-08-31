import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

final class ExpectedPlantMismatchConsent extends StatelessWidget {
  const ExpectedPlantMismatchConsent({
    super.key,
    required this.expectedPlantName,
    required this.value,
    required this.onChanged,
  });

  final String expectedPlantName;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    key: const ValueKey('field-accept-mismatch'),
    value: value,
    onChanged: onChanged,
    title: Text(
      'Abweichenden Vorschlag bewusst übernehmen',
      style: AppTypography.textTheme.titleSmall,
    ),
    subtitle: Text(
      'Gesucht war $expectedPlantName. Der gewählte Vorschlag stimmt damit nicht sicher überein.',
    ),
    controlAffinity: ListTileControlAffinity.leading,
    tileColor: AppColors.warningBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.warningBorder),
    ),
  );
}
