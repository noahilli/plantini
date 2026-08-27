import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/plant_model.dart';

/// Screen presenting the detailed plant profile ("Pflanzensteckbrief").
class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key, required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final hasWarning =
        plant.warning != null && plant.warning!.trim().isNotEmpty;
    final title = plant.commonName.isNotEmpty
        ? plant.commonName
        : plant.scientificName;

    return Scaffold(
      appBar: AppBar(title: const Text('Steckbrief')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 168,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.sage200,
                borderRadius: BorderRadius.circular(26),
                gradient: plant.media.isEmpty
                    ? const LinearGradient(
                        colors: [AppColors.sage200, AppColors.sage300],
                      )
                    : null,
              ),
              child: plant.media.isEmpty
                  ? const Icon(
                      Icons.local_florist,
                      size: 76,
                      color: AppColors.sage500,
                    )
                  : Image.network(
                      plant.media.first.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.local_florist,
                        size: 76,
                        color: AppColors.sage500,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            Text(
              title,
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              plant.scientificName,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 9),

            // Familie
            if (plant.family.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plant.family,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Warnung falls vorhanden (gelbe Box)
            if (hasWarning) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(
                    color: AppColors.warningBorder,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.bark,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        plant.warning!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.bark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Medien-Galerie
            if (plant.media.isNotEmpty) ...[
              Text(
                'Galerie',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: plant.media.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final media = plant.media[index];
                    return _PlantMediaCard(media: media);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Beschreibung
            Text(
              'Beschreibung',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plant.description.isNotEmpty
                  ? plant.description
                  : 'Keine Beschreibung vorhanden.',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Quellen-Liste am Ende
            if (plant.sources.isNotEmpty) ...[
              const Divider(color: AppColors.line),
              const SizedBox(height: 12),
              Text(
                'Quellen',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 8),
              ...plant.sources.map(
                (source) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      Expanded(
                        child: Text(
                          source,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlantMediaCard extends StatelessWidget {
  const _PlantMediaCard({required this.media});

  final PlantMedia media;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              media.url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.beige,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.muted,
                  size: 36,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.beige,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.forest,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (media.altText.isNotEmpty)
                  Text(
                    media.altText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                Text(
                  'Lizenz: ${media.license}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                if (media.author != null && media.author!.isNotEmpty)
                  Text(
                    'Autor: ${media.author}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
