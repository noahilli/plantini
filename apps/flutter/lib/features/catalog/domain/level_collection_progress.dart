import 'catalog_models.dart';

/// Server-compatible view of a level's field-collection gate.
final class LevelCollectionProgress {
  const LevelCollectionProgress({
    required this.requiredPlantIds,
    required this.collectedPlantIds,
  });

  factory LevelCollectionProgress.forLevel(
    Level level,
    Iterable<String> confirmedPlantIds,
  ) {
    final collected = confirmedPlantIds.toSet();
    final targets = level.collectionTargets;
    return LevelCollectionProgress(
      requiredPlantIds: targets,
      collectedPlantIds: targets.where(collected.contains).toSet(),
    );
  }

  final List<String> requiredPlantIds;
  final Set<String> collectedPlantIds;

  int get collectedCount => collectedPlantIds.length;
  int get requiredCount => requiredPlantIds.length;
  bool get isComplete =>
      requiredPlantIds.isNotEmpty && collectedCount == requiredCount;
  double get fraction =>
      requiredCount == 0 ? 0 : collectedCount / requiredCount;
  List<String> get missingPlantIds => requiredPlantIds
      .where((plantId) => !collectedPlantIds.contains(plantId))
      .toList(growable: false);
}
