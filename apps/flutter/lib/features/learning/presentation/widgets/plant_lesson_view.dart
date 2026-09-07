import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../catalog/domain/catalog_models.dart';

/// Uses the same published plant descriptions as catalog, without local facts.
final class PlantLessonView extends StatelessWidget {
  const PlantLessonView({
    super.key,
    required this.level,
    required this.plants,
    required this.onStart,
  });

  final Level level;
  final List<Plant> plants;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      Text(
        'DEINE KURZE PFLANZENLEKTION',
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: AppColors.sage800),
      ),
      const SizedBox(height: 8),
      Text(level.title, style: Theme.of(context).textTheme.headlineMedium),
      if (level.learningGoal case final String goal) ...[
        const SizedBox(height: 8),
        Text(goal),
      ],
      const SizedBox(height: 20),
      for (final plant in plants) ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.sage200,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  plant.commonName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                plant.scientificName,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Text(plant.description),
              if (plant.warning case final String warning) ...[
                const SizedBox(height: 12),
                Text(
                  warning,
                  style: const TextStyle(color: AppColors.accent800),
                ),
              ],
              if (plant.sources.isNotEmpty) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Quellen zur Pflanze'),
                  children: [
                    for (final source in plant.sources)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SelectableText(source),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      FilledButton.icon(
        key: const ValueKey('learning-start-quiz'),
        onPressed: onStart,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Los geht’s – zum Quiz'),
      ),
    ],
  );
}
