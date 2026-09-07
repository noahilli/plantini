import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../domain/catalog_models.dart';
import '../domain/catalog_repository.dart';
import 'models/isar_level.dart';
import 'models/isar_plant.dart';

import 'package:isar_plus/isar_plus.dart';

class IsarCatalogRepository implements CatalogRepository {
  IsarCatalogRepository({required this.localDb, required this.fallback});

  final LocalDatabase? localDb;
  final CatalogRepository fallback;

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() async {
    final online = await fallback.listPublishedEcosystems();
    if (online is Success<List<Ecosystem>>) return online;
    final db = localDb;
    if (db == null) return online;

    try {
      final isarEcosystems = db.ecosystems.where().findAll();
      if (isarEcosystems.isNotEmpty) {
        final ecosystems = isarEcosystems
            .map(
              (e) => Ecosystem(
                id: e.publicId,
                slug: e.slug,
                title: e.title,
                releaseVersion: e.releaseVersion,
                levelIds: e.levelIds,
                description: e.description,
              ),
            )
            .toList();
        return Result.success(ecosystems);
      }
    } catch (e) {
      // fallback
    }

    return online;
  }

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) async {
    // Progress changes after each quiz. Published Isar content is a fallback,
    // never the authority for fresh unlocks.
    final online = await fallback.getPublishedLevel(levelId);
    if (online is Success<LevelContent>) return online;
    final db = localDb;
    if (db == null) return online;

    try {
      final isarLevel = db.levels.where().publicIdEqualTo(levelId).findFirst();
      if (isarLevel != null) {
        final level = Level(
          id: isarLevel.publicId,
          ecosystemId: isarLevel.ecosystemId,
          title: isarLevel.title,
          sequence: isarLevel.sequence,
          status: _mapStatus(isarLevel.status),
          minimumScore: isarLevel.minimumScore,
          requiredQuizIds: isarLevel.requiredQuizIds,
          plantIds: isarLevel.plantIds,
          requiredPlantIds: isarLevel.requiredPlantIds,
          learningGoal: isarLevel.learningGoal,
          progress: isarLevel.progress,
          blockedReason: isarLevel.blockedReason,
        );
        return Result.success(
          LevelContent(level: level, contentVersion: isarLevel.contentVersion),
        );
      }
    } catch (e) {
      // fallback
    }

    return online;
  }

  @override
  Future<Result<Plant>> getPublishedPlant(String plantId) async {
    final db = localDb;
    if (db == null) return fallback.getPublishedPlant(plantId);
    try {
      final stored = db.plants.where().publicIdEqualTo(plantId).findFirst();
      if (stored != null) {
        return Result.success(
          Plant(
            id: stored.publicId,
            slug: stored.slug,
            scientificName: stored.scientificName,
            commonName: stored.commonName,
            family: stored.family,
            description: stored.description,
            warning: stored.warning,
            sources: stored.sources,
            releaseVersion: stored.releaseVersion,
            media: stored.media
                .map(
                  (item) => PlantMedia(
                    id: item.publicId,
                    slug: item.slug,
                    url: item.url,
                    altText: item.altText,
                    license: item.license,
                    author: item.author,
                  ),
                )
                .toList(growable: false),
          ),
        );
      }
    } catch (_) {
      // A corrupt or unavailable local cache must not hide online content.
    }
    return fallback.getPublishedPlant(plantId);
  }

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) async {
    final online = await fallback.listPublishedLevels(ecosystemId);
    if (online is Success<List<Level>>) return online;
    final db = localDb;
    if (db == null) return online;

    try {
      final isarLevels = db.levels
          .where()
          .ecosystemIdEqualTo(ecosystemId)
          .findAll();
      if (isarLevels.isNotEmpty) {
        final levels = isarLevels
            .map(
              (isarLevel) => Level(
                id: isarLevel.publicId,
                ecosystemId: isarLevel.ecosystemId,
                title: isarLevel.title,
                sequence: isarLevel.sequence,
                status: _mapStatus(isarLevel.status),
                minimumScore: isarLevel.minimumScore,
                requiredQuizIds: isarLevel.requiredQuizIds,
                plantIds: isarLevel.plantIds,
                requiredPlantIds: isarLevel.requiredPlantIds,
                learningGoal: isarLevel.learningGoal,
                progress: isarLevel.progress,
                blockedReason: isarLevel.blockedReason,
              ),
            )
            .toList();

        // Sort levels by sequence
        levels.sort((a, b) => a.sequence.compareTo(b.sequence));
        return Result.success(levels);
      }
    } catch (e) {
      // fallback
    }

    return online;
  }

  LevelStatus _mapStatus(IsarLevelStatus status) {
    switch (status) {
      case IsarLevelStatus.locked:
        return LevelStatus.locked;
      case IsarLevelStatus.available:
        return LevelStatus.available;
      case IsarLevelStatus.inProgress:
        return LevelStatus.inProgress;
      case IsarLevelStatus.completed:
        return LevelStatus.completed;
    }
  }
}
