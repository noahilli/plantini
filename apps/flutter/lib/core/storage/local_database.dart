import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/catalog/infrastructure/models/isar_ecosystem.dart';
import '../../features/catalog/infrastructure/models/isar_level.dart';
import '../../features/catalog/infrastructure/models/isar_plant.dart';
import '../errors/app_failure.dart';
import '../result.dart';

/// Local offline database wrapper around an [Isar] instance.
final class LocalDatabase {
  const LocalDatabase(this._isar);

  final Isar _isar;

  Isar get isar => _isar;

  IsarCollection<IsarEcosystem> get ecosystems => _isar.isarEcosystems;
  IsarCollection<IsarLevel> get levels => _isar.isarLevels;
  IsarCollection<IsarPlant> get plants => _isar.isarPlants;

  static const List<CollectionSchema<dynamic>> schemas = [
    IsarEcosystemSchema,
    IsarLevelSchema,
    IsarPlantSchema,
  ];

  /// Opens or reuses an existing [Isar] database instance.
  static Future<Result<LocalDatabase>> open({
    String? directory,
    String name = 'plantini_local_db',
    bool inspector = false,
  }) async {
    try {
      final existing = Isar.getInstance(name);
      if (existing != null && existing.isOpen) {
        return Result.success(LocalDatabase(existing));
      }

      final dbDir =
          directory ?? (await getApplicationDocumentsDirectory()).path;
      final isarInstance = await Isar.open(
        schemas,
        directory: dbDir,
        name: name,
        inspector: inspector,
      );
      return Result.success(LocalDatabase(isarInstance));
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Die lokale Datenbank konnte nicht geöffnet werden.',
          cause: error,
        ),
      );
    }
  }

  /// Closes the database instance.
  Future<void> close({bool deleteFromDisk = false}) async {
    if (_isar.isOpen) {
      await _isar.close(deleteFromDisk: deleteFromDisk);
    }
  }
}
