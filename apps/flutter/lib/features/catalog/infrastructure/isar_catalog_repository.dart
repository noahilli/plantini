import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../domain/catalog_models.dart';
import '../domain/catalog_repository.dart';
import 'models/isar_level.dart';

import 'package:isar/isar.dart';

class IsarCatalogRepository implements CatalogRepository {
  IsarCatalogRepository({required this.localDb, required this.fallback});

  final LocalDatabase? localDb;
  final CatalogRepository fallback;

  @override
  Future<Result<List<Ecosystem>>> listPublishedEcosystems() async {
    final db = localDb;
    if (db == null) return fallback.listPublishedEcosystems();

    try {
      final isarEcosystems = await db.ecosystems.where().findAll();
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

    return fallback.listPublishedEcosystems();
  }

  @override
  Future<Result<LevelContent>> getPublishedLevel(String levelId) async {
    final db = localDb;
    if (db == null) return fallback.getPublishedLevel(levelId);

    try {
      final isarLevel = await db.levels
          .filter()
          .publicIdEqualTo(levelId)
          .findFirst();
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

    return fallback.getPublishedLevel(levelId);
  }

  @override
  Future<Result<List<Level>>> listPublishedLevels(String ecosystemId) async {
    final db = localDb;
    if (db == null) return fallback.listPublishedLevels(ecosystemId);

    try {
      final isarLevels = await db.levels
          .filter()
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

    return fallback.listPublishedLevels(ecosystemId);
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
