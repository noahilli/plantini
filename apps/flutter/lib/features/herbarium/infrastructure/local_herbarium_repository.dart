import 'dart:convert';

import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/storage/models/isar_sync_queue.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';

/// Local offline-first implementation of [HerbariumRepository].
/// Reads from and writes to [LocalDatabase] (Isar) when available,
/// maintaining an in-memory cache and seed dataset for instant offline exploration.
final class LocalHerbariumRepository implements HerbariumRepository {
  LocalHerbariumRepository({
    this.database,
    List<HerbariumEntry>? initialEntries,
  }) {
    if (initialEntries != null) {
      _entries.addAll(initialEntries);
    } else {
      _seedDefaultEntries();
    }
  }

  final LocalDatabase? database;
  final List<HerbariumEntry> _entries = [];

  void _seedDefaultEntries() {
    _entries.addAll([
      HerbariumEntry(
        id: 'herb-001',
        observedAt: DateTime.parse('2026-08-25T14:30:00.000Z'),
        plantName: 'Stieleiche',
        scientificName: 'Quercus robur',
        note: 'Prachtvolles altes Exemplar am Waldrand entdeckt. Auffallend gelappte Blätter.',
        confirmedPlantId: 'quercus-robur',
        identificationJobId: 'job-001',
        identificationResult: 'PlantNet KI: Quercus robur (98% Konfidenz)',
        mediaUrl: 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=800',
        version: 'v1',
        syncStatus: SyncStatus.synced,
        latitude: 48.137154,
        longitude: 11.576124,
      ),
      HerbariumEntry(
        id: 'herb-002',
        observedAt: DateTime.parse('2026-08-26T09:15:00.000Z'),
        plantName: 'Gänseblümchen',
        scientificName: 'Bellis perennis',
        note: 'Auf der sonnigen Schlosswiese gesammelt. Weiße Blütenblätter mit gelber Scheibe.',
        confirmedPlantId: 'bellis-perennis',
        identificationJobId: 'job-002',
        identificationResult: 'PlantNet KI: Bellis perennis (95% Konfidenz)',
        mediaUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800',
        version: 'v1',
        syncStatus: SyncStatus.pending,
        latitude: 48.140232,
        longitude: 11.580194,
      ),
      HerbariumEntry(
        id: 'herb-003',
        observedAt: DateTime.parse('2026-08-24T16:45:00.000Z'),
        plantName: 'Löwenzahn',
        scientificName: 'Taraxacum officinale',
        note: 'Kräftige Pusteblume neben dem Wanderweg gefunden.',
        confirmedPlantId: 'taraxacum-officinale',
        identificationJobId: 'job-003',
        identificationResult: 'PlantNet KI: Taraxacum officinale (92% Konfidenz)',
        mediaUrl: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=800',
        version: 'v1',
        syncStatus: SyncStatus.synced,
        latitude: 48.135001,
        longitude: 11.572000,
      ),
      HerbariumEntry(
        id: 'herb-004',
        observedAt: DateTime.parse('2026-08-23T11:20:00.000Z'),
        plantName: 'Große Brennnessel',
        scientificName: 'Urtica dioica',
        note: 'Am Uferbereich eines kleinen Bachlaufs gewachsen.',
        confirmedPlantId: 'urtica-dioica',
        identificationJobId: 'job-004',
        identificationResult: 'PlantNet KI: Urtica dioica (89% Konfidenz)',
        mediaUrl: null,
        version: 'v1',
        syncStatus: SyncStatus.conflict,
        latitude: 48.131100,
        longitude: 11.568900,
      ),
    ]);
  }

  @override
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final db = database;
      if (db != null && db.isar.isOpen) {
        // Read stored queue items to augment local observations
        final queueJobs = await db.syncQueue.where().findAll();
        for (final job in queueJobs) {
          if (job.payload.isNotEmpty && !_entries.any((e) => e.id == job.clientId)) {
            try {
              final data = jsonDecode(job.payload) as Map<String, dynamic>;
              final entry = HerbariumEntry(
                id: job.clientId,
                observedAt: job.createdAt,
                note: data['note'] as String? ?? '',
                confirmedPlantId: data['plantId'] as String?,
                plantName: data['plantName'] as String?,
                scientificName: data['scientificName'] as String?,
                identificationResult: data['identificationResult'] as String?,
                mediaUrl: data['mediaUrl'] as String?,
                version: 'v1',
                syncStatus: switch (job.status) {
                  SyncJobStatus.completed => SyncStatus.synced,
                  SyncJobStatus.failed => SyncStatus.conflict,
                  _ => SyncStatus.pending,
                },
              );
              _entries.add(entry);
            } catch (_) {
              // Ignore payload parse errors for non-herbarium jobs
            }
          }
        }
      }

      // Sort newest first
      _entries.sort((a, b) => b.observedAt.compareTo(a.observedAt));

      final startIndex = (page - 1) * pageSize;
      if (startIndex >= _entries.length) {
        return const Result.success([]);
      }
      final endIndex = (startIndex + pageSize).clamp(0, _entries.length);
      final paged = _entries.sublist(startIndex, endIndex);

      return Result.success(List.unmodifiable(paged));
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Fehler beim Laden der Herbarium-Einträge.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<HerbariumEntry>> getEntry(String id) async {
    try {
      final match = _entries.where((e) => e.id == id).firstOrNull;
      if (match != null) {
        return Result.success(match);
      }
      return Result.failure(
        const NotFoundFailure(message: 'Herbarium-Eintrag wurde nicht gefunden.'),
      );
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Fehler beim Abrufen des Herbarium-Eintrags.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<HerbariumEntry>> createEntry({
    required String clientObservationId,
    required DateTime observedAt,
    String? note,
    String? mediaId,
    String? mediaUrl,
    String? plantName,
    String? scientificName,
    String? identificationResult,
    String? identificationJobId,
    required String idempotencyKey,
  }) async {
    try {
      final entry = HerbariumEntry(
        id: clientObservationId,
        observedAt: observedAt,
        note: note ?? '',
        plantName: plantName,
        scientificName: scientificName,
        identificationJobId: identificationJobId,
        identificationResult: identificationResult,
        mediaUrl: mediaUrl,
        version: 'v1',
        syncStatus: SyncStatus.pending,
      );

      _entries.removeWhere((e) => e.id == clientObservationId);
      _entries.insert(0, entry);

      final db = database;
      if (db != null && db.isar.isOpen) {
        final job = IsarSyncJob()
          ..clientId = clientObservationId
          ..payload = jsonEncode({
            'note': note,
            'mediaId': mediaId,
            'mediaUrl': mediaUrl,
            'plantName': plantName,
            'scientificName': scientificName,
            'identificationResult': identificationResult,
            'identificationJobId': identificationJobId,
          })
          ..status = SyncJobStatus.pending
          ..attemptCount = 0
          ..nextRetryAt = DateTime.now()
          ..createdAt = observedAt
          ..updatedAt = DateTime.now();

        await db.isar.writeTxn(() async {
          await db.syncQueue.put(job);
        });
      }

      return Result.success(entry);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Herbarium-Eintrag konnte nicht gespeichert werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  }) async {
    try {
      _entries.removeWhere((e) => e.id == id);

      final db = database;
      if (db != null && db.isar.isOpen) {
        final jobs = await db.syncQueue.where().findAll();
        final matching = jobs.where((j) => j.clientId == id).toList();
        if (matching.isNotEmpty) {
          await db.isar.writeTxn(() async {
            for (final job in matching) {
              await db.syncQueue.delete(job.id);
            }
          });
        }
      }

      return const Result.success(null);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Eintrag konnte nicht gelöscht werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<HerbariumEntry>>> syncEntries() async {
    try {
      for (var i = 0; i < _entries.length; i++) {
        if (_entries[i].syncStatus == SyncStatus.pending ||
            _entries[i].syncStatus == SyncStatus.conflict) {
          _entries[i] = _entries[i].copyWith(syncStatus: SyncStatus.synced);
        }
      }

      final db = database;
      if (db != null && db.isar.isOpen) {
        final jobs = await db.syncQueue.where().findAll();
        await db.isar.writeTxn(() async {
          for (final job in jobs) {
            job.status = SyncJobStatus.completed;
            job.updatedAt = DateTime.now();
            await db.syncQueue.put(job);
          }
        });
      }

      return Result.success(List.unmodifiable(_entries));
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Synchronisation fehlgeschlagen.',
          cause: error,
        ),
      );
    }
  }
}
