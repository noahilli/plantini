import 'package:isar_plus/isar_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/catalog/infrastructure/models/isar_ecosystem.dart';
import '../../features/catalog/infrastructure/models/isar_level.dart';
import '../../features/catalog/infrastructure/models/isar_plant.dart';
import '../errors/app_failure.dart';
import '../result.dart';
import 'models/isar_sync_queue.dart';

/// Local offline database wrapper around an [Isar] instance.
final class LocalDatabase {
  const LocalDatabase(this._isar);

  final Isar _isar;

  Isar get isar => _isar;

  IsarCollection<int, IsarEcosystem> get ecosystems => _isar.isarEcosystems;
  IsarCollection<int, IsarLevel> get levels => _isar.isarLevels;
  IsarCollection<int, IsarPlant> get plants => _isar.isarPlants;
  IsarCollection<int, IsarSyncJob> get syncQueue => _isar.isarSyncJobs;

  static final List<IsarGeneratedSchema> schemas = [
    IsarEcosystemSchema,
    IsarLevelSchema,
    IsarPlantSchema,
    IsarSyncJobSchema,
  ];

  /// Opens or reuses an existing [Isar] database instance.
  static Future<Result<LocalDatabase>> open({
    String? directory,
    String name = 'plantini_local_db',
    bool inspector = false,
  }) async {
    try {
      // Keep the web database bootstrap same-origin. Depending on Isar's
      // default CDN URL makes application startup depend on public DNS and an
      // external service, which is unacceptable for offline-first use.
      await Isar.initialize(kIsWeb ? '/isar_plus.wasm' : null);
      final dbDir =
          directory ??
          (kIsWeb ? '.' : (await getApplicationDocumentsDirectory()).path);
      final isarInstance = Isar.open(
        schemas: schemas,
        directory: dbDir,
        name: name,
        // Isar Plus persists web databases through its SQLite/WASM flavor.
        // Native targets retain the regular Isar engine and file format.
        engine: kIsWeb ? IsarEngine.sqlite : IsarEngine.isar,
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
      _isar.close(deleteFromDisk: deleteFromDisk);
    }
  }
}
