import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../design_system/plant_specimen_bottle.dart';
import '../../domain/catalog_models.dart';
import '../../domain/ecosystem_journey.dart';

/// Shown at the end of the map and accessible from the very first station.
final class EcosystemFinaleCard extends StatelessWidget {
  const EcosystemFinaleCard({
    super.key,
    required this.ecosystem,
    required this.levels,
    required this.targets,
    required this.plants,
    required this.journey,
    required this.onCollect,
    required this.onRefresh,
    this.progressError,
  });
  final Ecosystem ecosystem;
  final List<Level> levels;
  final List<String> targets;
  final Map<String, Plant> plants;
  final EcosystemJourney? journey;
  final ValueChanged<Plant> onCollect;
  final VoidCallback onRefresh;
  final String? progressError;
  @override
  Widget build(BuildContext context) {
    final completed = journey?.completed == true;
    final passed =
        journey?.completedLevelIds.length ??
        levels.where((l) => l.status == LevelStatus.completed).length;
    return Container(
      key: const ValueKey('ecosystem-finale'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.sage300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            completed ? Icons.emoji_events_rounded : Icons.flag_rounded,
            size: 48,
            color: AppColors.accent700,
          ),
          const SizedBox(height: 10),
          Text(
            completed
                ? '${ecosystem.title} gemeistert!'
                : 'Dein Ökosystem-Finale',
            key: ValueKey(
              completed ? 'ecosystem-completed' : 'ecosystem-incomplete',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            '$passed / ${levels.length} Level bestanden',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bestehe alle Level und fülle diese drei Gläser. Du kannst die Pflanzen jederzeit fotografieren und im Herbarium bestätigen – auch vor dem ersten Quiz.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 14),
          for (final id in targets)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    PlantSpecimenBottle(
                      collected:
                          journey?.collectedPlantIds.contains(id) == true,
                      height: 96,
                      plantName: plants[id]?.commonName,
                      scientificName: plants[id]?.scientificName,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plants[id]?.commonName ??
                                'Pflanzensteckbrief nicht verfügbar',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (journey?.collectedPlantIds.contains(id) == true)
                            const Text(
                              'Gesammelt ✓',
                              style: TextStyle(color: AppColors.sage700),
                            )
                          else if (plants[id] != null)
                            TextButton(
                              key: ValueKey('ecosystem-collect-$id'),
                              onPressed: () => onCollect(plants[id]!),
                              child: const Text('Pflanze suchen'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (journey == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                progressError ?? 'Dein Abschluss wird beim nächsten Online-Abgleich geprüft.',
                style: const TextStyle(color: AppColors.neutral700),
              ),
            ),
          OutlinedButton.icon(
            key: const ValueKey('ecosystem-check-completion'),
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Fortschritt prüfen'),
          ),
        ],
      ),
    );
  }
}
