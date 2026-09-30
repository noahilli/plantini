import 'package:flutter/material.dart';

import '../../../../core/images/plantini_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/collection_insights.dart';
import '../../domain/herbarium_models.dart';
import '../../domain/insight_repository.dart';

/// What everyone else knows about a find: how many accounts collected the
/// species and, for species outside the ecosystems, the shared info card.
/// Renders nothing while loading or when the server has nothing to say.
class FindInsights extends StatefulWidget {
  const FindInsights({super.key, required this.entry, required this.insights});

  final HerbariumEntry entry;
  final InsightRepository? insights;

  @override
  State<FindInsights> createState() => _FindInsightsState();
}

class _FindInsightsState extends State<FindInsights> {
  String? _sentence;
  SpeciesCard? _card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(FindInsights old) {
    super.didUpdateWidget(old);
    if (old.entry.id != widget.entry.id) _load();
  }

  Future<void> _load() async {
    final insights = widget.insights;
    final entry = widget.entry;
    if (insights == null) return;
    final stats = await insights.collectionStats();
    final key = entry.speciesKey;
    final card = key == null ? null : await insights.speciesCard(key);
    if (!mounted || entry.id != widget.entry.id) return;
    setState(() {
      _sentence = stats.valueOrNull?.sentenceFor(
        plantId: entry.confirmedPlantId,
        speciesKey: key,
      );
      _card = card?.valueOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentence = _sentence;
    final card = _card;
    if (sentence == null && card == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sentence != null)
          Container(
            key: const ValueKey('find-collection-share'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.sage100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_2_rounded,
                  size: 20,
                  color: AppColors.sage700,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(sentence)),
              ],
            ),
          ),
        if (card != null) ...[
          const SizedBox(height: 12),
          _SpeciesCardView(card: card),
        ],
      ],
    );
  }
}

class _SpeciesCardView extends StatelessWidget {
  const _SpeciesCardView({required this.card});

  final SpeciesCard card;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('find-species-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (card.photoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: PlantiniImage(
                        card.photoUrl!,
                        authenticated: true,
                        decodeWidth: 84,
                        semanticLabel: card.scientificName,
                        errorBuilder: (_, _) => const ColoredBox(
                          color: AppColors.sage200,
                          child: Icon(Icons.local_florist_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.commonName ?? card.scientificName,
                      style: textTheme.titleMedium,
                    ),
                    if (card.commonName != null)
                      Text(
                        card.scientificName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (card.photoAttribution != null)
                      Text(
                        'Foto: ${card.photoAttribution}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (card.summary != null) ...[
            const SizedBox(height: 10),
            Text(card.summary!, maxLines: 6, overflow: TextOverflow.ellipsis),
            if (card.summarySource != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Quelle: ${card.summarySource} (CC BY-SA 4.0)',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 8),
          Text(
            'Artkarte aus öffentlichen Quellen, nicht redaktionell geprüft. '
            'Sie gehört zu keinem Ökosystem.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}
