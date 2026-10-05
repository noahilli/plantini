import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../catalog/domain/catalog_models.dart';
import '../../../catalog/presentation/widgets/plant_index_card.dart';

/// A short, readable field notebook shown before a level's three questions.
final class PlantLessonView extends StatelessWidget {
  const PlantLessonView({
    super.key,
    required this.level,
    required this.plants,
    required this.onStart,
    this.startLabel = 'Jetzt 3 Fragen beantworten',
  });

  final Level level;
  final List<Plant> plants;
  final VoidCallback onStart;
  final String startLabel;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1040),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          _MissionHeader(level: level),
          const SizedBox(height: 20),
          for (final plant in plants) ...[
            PlantIndexCard(plant: plant),
            const SizedBox(height: 18),
          ],
          FilledButton.icon(
            key: const ValueKey('learning-start-quiz'),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(startLabel),
          ),
          const SizedBox(height: 10),
          Text(
            'Lies in deinem Tempo – es gibt kein Zeitlimit.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.neutral700),
          ),
        ],
      ),
    ),
  );
}

final class _MissionHeader extends StatelessWidget {
  const _MissionHeader({required this.level});
  final Level level;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.sage800,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.sage200),
            const SizedBox(width: 8),
            Text(
              'FELDNOTIZ · LEVEL ${level.sequence}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.sage200,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          level.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.neutral100,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (level.learningGoal case final String goal) ...[
          const SizedBox(height: 8),
          Text(goal, style: const TextStyle(color: AppColors.neutral100)),
        ],
        const SizedBox(height: 18),
        const _MissionSteps(),
      ],
    ),
  );
}

final class _MissionSteps extends StatelessWidget {
  const _MissionSteps();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      _MissionStep(icon: Icons.menu_book_outlined, label: 'Steckbrief'),
      _MissionArrow(),
      _MissionStep(icon: Icons.quiz_outlined, label: '3 Fragen'),
      _MissionArrow(),
      _MissionStep(icon: Icons.star_outline_rounded, label: 'Stern'),
    ],
  );
}

final class _MissionStep extends StatelessWidget {
  const _MissionStep({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: AppColors.accent300),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.neutral100, fontSize: 11),
        ),
      ],
    ),
  );
}

final class _MissionArrow extends StatelessWidget {
  const _MissionArrow();

  @override
  Widget build(BuildContext context) => const Icon(
    Icons.arrow_forward_rounded,
    size: 18,
    color: AppColors.sage300,
  );
}
