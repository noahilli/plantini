import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/plant_model.dart';

/// Photos and their attribution stay together, including in the lesson notebook.
final class PlantPhotoGallery extends StatelessWidget {
  const PlantPhotoGallery({super.key, required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (plant.media.isEmpty)
        _unavailable('Noch kein Pflanzenfoto hinterlegt'),
      for (final media in plant.media) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.network(
            media.url,
            height: 240,
            fit: BoxFit.contain,
            semanticLabel: media.altText,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
            errorBuilder: (_, _, _) =>
                _unavailable('Pflanzenfoto momentan nicht verfügbar'),
          ),
        ),
        const SizedBox(height: 8),
        if (media.automatic)
          const Text(
            'Automatisch zugeordnet · botanisch nicht redaktionell geprüft',
            style: TextStyle(fontSize: 12),
          ),
        Text(media.altText, style: Theme.of(context).textTheme.bodySmall),
        SelectableText(
          [
            if (media.author?.isNotEmpty == true) media.author!,
            media.license,
          ].join(' · '),
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.neutral700),
        ),
        if (media.source?.isNotEmpty == true)
          SelectableText(
            'Bildquelle: ${media.source}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (media.licenseUrl?.isNotEmpty == true)
          SelectableText(
            'Lizenz: ${media.licenseUrl}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 16),
      ],
    ],
  );

  Widget _unavailable(String message) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.sage100, AppColors.sage200],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.local_florist_outlined,
          size: 64,
          color: AppColors.sage700,
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        const Text(
          'Symbolbild – keine Bestimmungshilfe',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
