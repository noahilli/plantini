import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/plant_model.dart';
import 'plant_photo_gallery.dart';

/// A live, accessible index-card template, composed from editorial CMS content.
/// No facts are inferred from names or generated at presentation time.
final class PlantIndexCard extends StatelessWidget {
  const PlantIndexCard({super.key, required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 920),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: const BoxDecoration(
              color: AppColors.sage800,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Text(
              'PLANTINI  /  ARTENKARTEI',
              style: TextStyle(
                color: AppColors.neutral100,
                fontSize: 11,
                letterSpacing: 1.7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            key: ValueKey('plant-index-card-${plant.id}'),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.sage300),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sage900.withValues(alpha: .10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENTDECKEN · ERKENNEN · MERKEN',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.sage700,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        header: true,
                        child: Text(
                          plant.commonName.isEmpty
                              ? plant.scientificName
                              : plant.commonName,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: AppColors.sage900),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.scientificName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.sage700,
                            ),
                      ),
                      if (plant.family.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'FAMILIE  ·  ${plant.family}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.sage300),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final picture = Padding(
                      padding: const EdgeInsets.all(20),
                      child: PlantPhotoGallery(plant: plant),
                    );
                    final facts = Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Fact(
                            icon: Icons.visibility_outlined,
                            heading: 'Auf einen Blick',
                            text: plant.description.isEmpty
                                ? 'Noch keine Beschreibung hinterlegt.'
                                : plant.description,
                          ),
                          for (
                            var i = 0;
                            i < plant.profileCards.length;
                            i++
                          ) ...[
                            const SizedBox(height: 18),
                            _Fact(
                              icon: [
                                Icons.eco_outlined,
                                Icons.landscape_outlined,
                                Icons.lightbulb_outline,
                              ][i % 3],
                              heading: plant.profileCards[i].heading,
                              text: plant.profileCards[i].text,
                            ),
                          ],
                        ],
                      ),
                    );
                    final wide =
                        constraints.maxWidth >= 680 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 24;
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: picture),
                              Expanded(child: facts),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [picture, facts],
                          );
                  },
                ),
                if (plant.warning?.trim().isNotEmpty == true)
                  Container(
                    color: AppColors.accent100,
                    padding: const EdgeInsets.all(20),
                    child: _Fact(
                      icon: Icons.warning_amber_rounded,
                      heading: 'Achtsam entdecken',
                      text: plant.warning!,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ExpansionTile(
                    title: const Text('Quellen & Hintergrund'),
                    children: [
                      for (final source in plant.sources)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableText(source),
                        ),
                      if (plant.sources.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text('Noch keine Quellen hinterlegt.'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

final class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.heading, required this.text});
  final IconData icon;
  final String heading;
  final String text;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.sage700),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              heading,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.sage800,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(text, style: const TextStyle(height: 1.55)),
    ],
  );
}
