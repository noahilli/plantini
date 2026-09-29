import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../design_system/plant_specimen_bottle.dart';
import '../../../catalog/application/catalog_use_cases.dart';
import '../../../catalog/domain/catalog_models.dart';
import '../../../catalog/presentation/widgets/ecosystem_vitrine.dart';
import '../../../catalog/presentation/widgets/modular_forest_view.dart'
    show EcosystemWorld;
import '../../domain/herbarium_models.dart';

/// Catalog loading is independent of observations, so a failed content request
/// never prevents opening, editing, or syncing a personal observation.
class HerbariumBottleCollection extends StatefulWidget {
  const HerbariumBottleCollection({
    super.key,
    required this.loadEcosystems,
    required this.loadLevels,
    required this.loadPlant,
    required this.entries,
    required this.onEntryTap,
    required this.onStartField,
    required this.onRefreshEntries,
    this.searchQuery = '',
    this.selectedStatus,
    this.entriesAvailable = true,
    this.onDiscoverPlant,
  });

  final LoadPublishedEcosystems loadEcosystems;
  final LoadPublishedLevels loadLevels;
  final LoadPublishedPlant loadPlant;
  final List<HerbariumEntry> entries;
  final ValueChanged<HerbariumEntry> onEntryTap;
  final VoidCallback onStartField;
  final Future<void> Function() onRefreshEntries;
  final String searchQuery;
  final SyncStatus? selectedStatus;
  final bool entriesAvailable;
  final ValueChanged<Plant>? onDiscoverPlant;

  @override
  State<HerbariumBottleCollection> createState() =>
      _HerbariumBottleCollectionState();
}

class _HerbariumBottleCollectionState extends State<HerbariumBottleCollection> {
  final Map<String, List<Plant>> _groups = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final groups = <String, List<Plant>>{};
    String? error;
    try {
      final ecosystemsResult = await widget.loadEcosystems();
      final ecosystems = ecosystemsResult.valueOrNull;
      if (ecosystems == null) {
        throw StateError(
          ecosystemsResult.failureOrNull?.message ??
              'Ökosysteme konnten nicht geladen werden.',
        );
      }
      final seen = <String>{};
      // Deduplicate globally, including species appearing in several levels or
      // ecosystems. A shared species lives on its first ecosystem's shelf.
      for (final ecosystem in ecosystems) {
        final levelsResult = await widget.loadLevels(ecosystem.id);
        final levels = levelsResult.valueOrNull;
        if (levels == null) {
          error =
              levelsResult.failureOrNull?.message ??
              'Level konnten nicht geladen werden.';
          continue;
        }
        final ids = <String>{
          for (final level in levels) ...[
            ...level.plantIds,
            ...level.requiredPlantIds,
          ],
        }.where((id) => id.isNotEmpty && seen.add(id)).toList();
        final plants = <Plant>[];
        // Small batches avoid flooding the content API for large catalogs.
        for (var start = 0; start < ids.length; start += 6) {
          final results = await Future.wait(
            ids.skip(start).take(6).map(widget.loadPlant.call),
          );
          for (var i = 0; i < results.length; i++) {
            final result = results[i];
            if (result case Success<Plant>(:final value)
                when value.id == ids[start + i]) {
              plants.add(value);
            } else {
              error =
                  result.failureOrNull?.message ??
                  'Ein Pflanzensteckbrief fehlt.';
            }
          }
        }
        if (plants.isNotEmpty) {
          groups.putIfAbsent(ecosystem.title, () => []).addAll(plants);
        }
      }
    } catch (_) {
      error = 'Der Pflanzenkatalog konnte nicht vollständig geladen werden.';
    }
    if (!mounted) return;
    setState(() {
      _groups
        ..clear()
        ..addAll(groups);
      _error = error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entriesByPlant = <String, List<HerbariumEntry>>{};
    for (final entry in widget.entries) {
      if (entry.confirmedPlantId != null &&
          entry.syncStatus != SyncStatus.deleted) {
        entriesByPlant
            .putIfAbsent(entry.confirmedPlantId!, () => [])
            .add(entry);
      }
    }
    final query = widget.searchQuery.trim().toLowerCase();
    final filtered = <String, List<Plant>>{};
    for (final group in _groups.entries) {
      final plants = group.value.where((plant) {
        final matches = entriesByPlant[plant.id] ?? const <HerbariumEntry>[];
        return (widget.selectedStatus == null ||
                matches.any((e) => e.syncStatus == widget.selectedStatus)) &&
            (query.isEmpty ||
                plant.commonName.toLowerCase().contains(query) ||
                plant.scientificName.toLowerCase().contains(query) ||
                group.key.toLowerCase().contains(query) ||
                matches.any((e) => e.note.toLowerCase().contains(query)));
      }).toList();
      if (plants.isNotEmpty) filtered[group.key] = plants;
    }
    final total = _groups.values.expand((plants) => plants).length;
    final collected = _groups.values
        .expand((plants) => plants)
        .where((plant) => entriesByPlant.containsKey(plant.id))
        .length;
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_loadCatalog(), widget.onRefreshEntries()]);
      },
      child: ListView(
        key: const ValueKey('herbarium-bottle-collection'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
        children: [
          Text(
            'Dein kleines Naturmuseum',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: AppColors.forest),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jede Art hat ihr eigenes Glas. Bestätige einen Fund und lass deine Sammlung wachsen.',
          ),
          const SizedBox(height: 8),
          if (widget.entriesAvailable && !_loading && _error == null)
            Text(
              '$collected von $total Arten gesammelt',
              style: const TextStyle(
                color: AppColors.forest,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (widget.entries.any(
            (e) =>
                e.confirmedPlantId != null &&
                (e.syncStatus == SyncStatus.pending ||
                    e.syncStatus == SyncStatus.conflict),
          ))
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Lokale Funde sind vorläufig. Nach dem Abgleich zählen sie auch für dein Ökosystem-Finale.',
                style: TextStyle(color: AppColors.bark),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Pflanzenkatalog wird geladen …'),
                ],
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              'Katalog unvollständig. $_error Deine Funde bleiben unter „Beobachtungen“ erreichbar.',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('herbarium-catalog-retry'),
                onPressed: _loading ? null : _loadCatalog,
                icon: const Icon(Icons.refresh),
                label: const Text('Katalog erneut laden'),
              ),
            ),
          ],
          if (!_loading && _error == null && filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                total == 0
                    ? 'Noch keine Pflanzen im veröffentlichten Katalog.'
                    : 'Keine Arten für diese Suche oder Filterung.',
              ),
            ),
          for (final group in filtered.entries) ...[
            _ShelfHeader(
              title: group.key,
              collected: (_groups[group.key] ?? group.value)
                  .where((plant) => entriesByPlant.containsKey(plant.id))
                  .length,
              total: (_groups[group.key] ?? group.value).length,
              showProgress: widget.entriesAvailable,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final columns = math.max(
                  1,
                  (constraints.maxWidth / (155 * math.max(1, textScale * .8)))
                      .floor(),
                );
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final plant in group.value)
                      SizedBox(
                        width: width,
                        child: _SpecimenCard(
                          plant: plant,
                          entries: entriesByPlant[plant.id] ?? const [],
                          entriesAvailable: widget.entriesAvailable,
                          onEntryTap: widget.onEntryTap,
                          onStartField: () => widget.onDiscoverPlant != null
                              ? widget.onDiscoverPlant!(plant)
                              : widget.onStartField(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// One display case per ecosystem: the miniature on the left, how much of the
/// shelf is filled on the right. Counts come from the catalogue and the
/// learner's own confirmed finds.
class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({
    required this.title,
    required this.collected,
    required this.total,
    required this.showProgress,
  });
  final String title;
  final int collected, total;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final world = EcosystemWorld.forSlug(title);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 14),
      child: Row(
        children: [
          if (world != null)
            SizedBox(
              width: 108,
              child: EcosystemVitrine(
                world: world,
                aspectRatio: 1.05,
                semanticLabel: 'Vitrine: $title',
              ),
            ),
          if (world != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.forest,
                  ),
                ),
                if (showProgress && total > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '$collected von $total Arten im Regal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: collected / total,
                      minHeight: 8,
                      color: AppColors.sage600,
                      backgroundColor: AppColors.sage200,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecimenCard extends StatelessWidget {
  const _SpecimenCard({
    required this.plant,
    required this.entries,
    required this.entriesAvailable,
    required this.onEntryTap,
    required this.onStartField,
  });
  final Plant plant;
  final List<HerbariumEntry> entries;
  final bool entriesAvailable;
  final ValueChanged<HerbariumEntry> onEntryTap;
  final VoidCallback onStartField;

  @override
  Widget build(BuildContext context) {
    final synced = entries.where(
      (entry) => entry.syncStatus == SyncStatus.synced,
    );
    final collected = entries.isNotEmpty;
    final status = collected
        ? synced.isNotEmpty
              ? 'Gesammelt'
              : 'Lokal · noch nicht synchronisiert'
        : entriesAvailable
        ? 'Noch zu entdecken'
        : 'Fundstatus unbekannt';
    return Material(
      key: ValueKey('herbarium-species-${plant.id}'),
      color: collected ? const Color(0xFFE8EEDC) : const Color(0xFFF7F3E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(
          color: collected ? const Color(0xFFB6C5A6) : const Color(0xFFE4DED0),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => collected
            ? onEntryTap(synced.isNotEmpty ? synced.first : entries.first)
            : onStartField(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              PlantSpecimenBottle(
                collected: collected,
                plantName: plant.commonName,
                scientificName: plant.scientificName,
              ),
              const SizedBox(height: 8),
              Text(
                plant.commonName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plant.scientificName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: collected ? AppColors.forest : AppColors.bark,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                collected ? 'Fund ansehen' : 'Pflanze bestimmen',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.forest,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
