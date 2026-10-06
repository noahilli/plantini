// Standalone design workbench only. Not imported by main.dart or the router.
// flutter run -t lib/dev/vitrine_preview.dart   (?daytime=night|evening|morning|noon)
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/catalog/presentation/widgets/ecosystem_vitrine.dart';
import '../features/catalog/presentation/widgets/modular_forest_view.dart';
import '../features/catalog/presentation/widgets/world_lighting.dart';

void main() {
  final name = Uri.base.queryParameters['daytime'];
  for (final phase in DayPhase.values) {
    if (phase.name == name) DayClock.pin(phase);
  }
  runApp(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final world in EcosystemWorld.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EcosystemVitrine(world: world, title: world.shortName),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
