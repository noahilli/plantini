import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/plant_model.dart';
import 'plant_photo_gallery.dart';

/// Responsive field sheet, composed solely from published editorial content.
final class PlantIndexCard extends StatefulWidget {
  const PlantIndexCard({super.key, required this.plant});
  final Plant plant;
  @override
  State<PlantIndexCard> createState() => _PlantIndexCardState();
}

final class _PlantIndexCardState extends State<PlantIndexCard> {
  Color _tone = const Color(0xFF75866B);
  @override
  void didUpdateWidget(covariant PlantIndexCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plant.id != widget.plant.id) _tone = const Color(0xFF75866B);
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final wash = Color.lerp(const Color(0xFFF6F2E7), _tone, .22)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Container(
          key: ValueKey('plant-index-card-${plant.id}'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color.lerp(const Color(0xFFFFFDF7), _tone, .06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE1DFD1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.sage900.withValues(alpha: .09),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= 720 &&
                  MediaQuery.textScalerOf(context).scale(16) <= 24;
              final inset = wide ? 32.0 : 20.0;
              final picture = PlantPhotoGallery(
                key: ValueKey(plant.id),
                plant: plant,
                background: wash,
                onPalette: (tone) {
                  if (mounted && tone != _tone) setState(() => _tone = tone);
                },
              );
              final intro = _Introduction(plant: plant, wash: wash);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: inset,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: wash,
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFFDADACB)),
                      ),
                    ),
                    child: const Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _Eyebrow(
                          'PLANTINI / FELDNOTIZEN',
                          icon: Icons.spa_outlined,
                        ),
                        Text(
                          'Die Natur im Detail',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.sage800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(inset, 28, inset, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Eyebrow('PFLANZENPORTRÄT'),
                        const SizedBox(height: 12),
                        Semantics(
                          header: true,
                          child: Text(
                            plant.commonName.isEmpty
                                ? plant.scientificName
                                : plant.commonName,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  fontSize: wide ? 42 : 32,
                                  color: AppColors.sage900,
                                  height: 1.15,
                                ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          plant.scientificName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: AppColors.sage700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: inset),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: picture),
                              const SizedBox(width: 28),
                              Expanded(flex: 5, child: intro),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              picture,
                              const SizedBox(height: 24),
                              intro,
                            ],
                          ),
                  ),
                  if (plant.profileCards.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(inset, 32, inset, 18),
                      child: const Row(
                        children: [
                          Flexible(
                            child: _Eyebrow(
                              'GENAU HINSEHEN',
                              icon: Icons.search_rounded,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(child: Divider(color: Color(0xFFD4D8C9))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: inset),
                      child: LayoutBuilder(
                        builder: (context, c) => Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (var i = 0; i < plant.profileCards.length; i++)
                              SizedBox(
                                width: wide
                                    ? (c.maxWidth - 16) / 2
                                    : c.maxWidth,
                                child: _FieldNote(
                                  number: i + 1,
                                  note: plant.profileCards[i],
                                  tint: i.isEven
                                      ? wash
                                      : const Color(0xFFF2E7D5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (plant.warning?.trim().isNotEmpty == true)
                    Padding(
                      padding: EdgeInsets.fromLTRB(inset, 24, inset, 0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8EBD7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE8CDA6)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: Color(0xFF83582C),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Achtsam entdecken',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF684321),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    plant.warning!,
                                    style: const TextStyle(
                                      color: Color(0xFF684321),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(inset, 16, inset, 12),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.library_books_outlined,
                          size: 20,
                        ),
                        title: const Text('Quellen & Hintergrund'),
                        subtitle: const Text('Wissen nachvollziehbar machen'),
                        children: [
                          for (final source in plant.sources)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SelectableText(source),
                              ),
                            ),
                          if (plant.sources.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text('Noch keine Quellen hinterlegt.'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

final class _Introduction extends StatelessWidget {
  const _Introduction({required this.plant, required this.wash});
  final Plant plant;
  final Color wash;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (plant.family.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: wash,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow('PFLANZENFAMILIE'),
              const SizedBox(height: 5),
              Text(
                plant.family,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.sage900,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
      const _Eyebrow('AUF EINEN BLICK'),
      const SizedBox(height: 12),
      Text(
        plant.description.isEmpty
            ? 'Noch keine Beschreibung hinterlegt.'
            : plant.description,
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: AppColors.sage900,
        ),
      ),
      const SizedBox(height: 20),
      const Divider(color: Color(0xFFD4D8C9)),
      const SizedBox(height: 12),
      const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_outlined, size: 19, color: AppColors.sage700),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nimm dir einen Moment. Vergleiche das Bild mit den Merkmalen.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.sage700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

final class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[
        Icon(icon, size: 17, color: AppColors.sage700),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: AppColors.sage700,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

final class _FieldNote extends StatelessWidget {
  const _FieldNote({
    required this.number,
    required this.note,
    required this.tint,
  });
  final int number;
  final PlantProfileCard note;
  final Color tint;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Color.lerp(Colors.white, tint, .55),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      border: Border.all(color: Color.lerp(tint, AppColors.sage700, .15)!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                number.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sage800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  note.heading,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: AppColors.sage900),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          note.text,
          style: const TextStyle(
            fontSize: 14,
            height: 1.65,
            color: AppColors.sage900,
          ),
        ),
      ],
    ),
  );
}
