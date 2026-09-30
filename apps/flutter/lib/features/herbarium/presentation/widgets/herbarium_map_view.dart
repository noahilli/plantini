import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/images/image_service.dart';
import '../../../../core/images/plantini_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/herbarium_models.dart';
import '../../domain/insight_repository.dart';
import 'find_insights.dart';
import 'map_tile_provider.dart';

/// Interactive map of the finds that have a location. Only the owner sees
/// their own places; the tiles come through the Plantini API.
class HerbariumMapView extends StatefulWidget {
  const HerbariumMapView({
    super.key,
    required this.entries,
    required this.onOpenEntry,
    this.insights,
  });

  final List<HerbariumEntry> entries;
  final ValueChanged<HerbariumEntry> onOpenEntry;
  final InsightRepository? insights;

  @override
  State<HerbariumMapView> createState() => _HerbariumMapViewState();
}

class _HerbariumMapViewState extends State<HerbariumMapView> {
  final _controller = MapController();

  List<HerbariumEntry> get _located => [
    for (final entry in widget.entries)
      if (entry.latitude != null &&
          entry.longitude != null &&
          entry.syncStatus != SyncStatus.deleted)
        entry,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CameraFit? _initialFit(List<HerbariumEntry> located) {
    if (located.length < 2) return null;
    return CameraFit.coordinates(
      coordinates: [
        for (final entry in located) LatLng(entry.latitude!, entry.longitude!),
      ],
      padding: const EdgeInsets.fromLTRB(56, 96, 56, 120),
      maxZoom: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final located = _located;
    final images = ImageService.shared;
    if (located.isEmpty || images == null) {
      return const _EmptyMap();
    }
    final first = LatLng(located.first.latitude!, located.first.longitude!);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: FlutterMap(
        key: ValueKey('map-${located.length}'),
        mapController: _controller,
        options: MapOptions(
          initialCenter: first,
          initialZoom: 13,
          initialCameraFit: _initialFit(located),
          minZoom: 3,
          maxZoom: 17,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'tiles/{z}/{x}/{y}',
            tileProvider: PlantiniTileProvider(images),
            userAgentPackageName: 'eu.plantini.app',
            maxNativeZoom: 17,
          ),
          MarkerLayer(
            markers: [
              for (final entry in located)
                Marker(
                  point: LatLng(entry.latitude!, entry.longitude!),
                  width: 54,
                  height: 62,
                  alignment: Alignment.topCenter,
                  child: _FindPin(entry: entry, onTap: () => _open(entry)),
                ),
            ],
          ),
          const SimpleAttributionWidget(
            source: Text('© OpenStreetMap-Mitwirkende'),
          ),
        ],
      ),
    );
  }

  void _open(HerbariumEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.neutral100,
      builder: (context) => _FindSheet(
        entry: entry,
        insights: widget.insights,
        onOpen: () {
          Navigator.of(context).pop();
          widget.onOpenEntry(entry);
        },
      ),
    );
  }
}

class _FindPin extends StatelessWidget {
  const _FindPin({required this.entry, required this.onTap});

  final HerbariumEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = entry.photoUrl(width: 320);
    return Semantics(
      button: true,
      label: 'Fund: ${entry.displayTitle}',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sage200,
                border: Border.all(color: AppColors.terracotta, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0x40000000), blurRadius: 6),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: photo == null
                  ? const Icon(Icons.local_florist_rounded, size: 22)
                  : PlantiniImage(
                      photo,
                      authenticated: true,
                      decodeWidth: 46,
                      errorBuilder: (_, _) =>
                          const Icon(Icons.local_florist_rounded, size: 22),
                    ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: AppColors.terracotta,
            ),
          ],
        ),
      ),
    );
  }
}

class _FindSheet extends StatelessWidget {
  const _FindSheet({
    required this.entry,
    required this.insights,
    required this.onOpen,
  });

  final HerbariumEntry entry;
  final InsightRepository? insights;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photo = entry.photoUrl(width: 720);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: photo == null
                        ? const ColoredBox(
                            color: AppColors.sage200,
                            child: Icon(Icons.local_florist_rounded, size: 34),
                          )
                        : PlantiniImage(
                            photo,
                            authenticated: true,
                            decodeWidth: 96,
                            errorBuilder: (_, _) => const ColoredBox(
                              color: AppColors.sage200,
                              child: Icon(Icons.local_florist_rounded),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.displayTitle, style: textTheme.titleLarge),
                      if (entry.scientificName != null &&
                          entry.scientificName != entry.displayTitle)
                        Text(
                          entry.scientificName!,
                          style: textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'Gefunden am ${_date(entry.observedAt)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FindInsights(entry: entry, insights: insights),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Fund öffnen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

class _EmptyMap extends StatelessWidget {
  const _EmptyMap();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_outlined, size: 56, color: AppColors.sage600),
          const SizedBox(height: 12),
          Text(
            'Noch keine Funde mit Ort',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Erlaube beim Speichern eines Fundes den Standort, dann erscheint er hier auf der Karte. Nur du siehst deine Fundorte.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
