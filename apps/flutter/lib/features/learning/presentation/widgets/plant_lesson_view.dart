import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../catalog/domain/catalog_models.dart';
import '../../../catalog/presentation/widgets/plant_photo_gallery.dart';

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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
    children: [
      _MissionHeader(level: level),
      const SizedBox(height: 20),
      for (final plant in plants) ...[
        _PlantNotebookPage(plant: plant),
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

final class _PlantNotebookPage extends StatelessWidget {
  const _PlantNotebookPage({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.neutral100,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.sage300),
      boxShadow: const [
        BoxShadow(
          color: AppColors.divider,
          offset: Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.local_florist_rounded, color: AppColors.sage700),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      plant.commonName,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    plant.scientificName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        PlantPhotoGallery(plant: plant),
        if (plant.family.isNotEmpty) ...[
          const SizedBox(height: 16),
          _NotebookFact(label: 'Familie', value: plant.family),
        ],
        if (plant.description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(plant.description),
        ],
        for (final card in plant.profileCards) ...[
          const SizedBox(height: 14),
          _ProfileCard(card: card),
        ],
        if (plant.warning case final String warning) ...[
          const SizedBox(height: 16),
          _WarningNote(text: warning),
        ],
        if (plant.sources.isNotEmpty) ...[
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Quellen und weiterforschen'),
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
  );
}

final class _NotebookFact extends StatelessWidget {
  const _NotebookFact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.sage100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text.rich(
        TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    ),
  );
}

final class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.card});
  final PlantProfileCard card;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.neutral200,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.heading,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.sage800,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(card.text),
        ],
      ),
    ),
  );
}

final class _WarningNote extends StatelessWidget {
  const _WarningNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.accent100,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accent300),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.accent800),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}
