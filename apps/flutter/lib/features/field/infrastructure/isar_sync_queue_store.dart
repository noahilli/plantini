import 'package:isar/isar.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/storage/models/isar_sync_queue.dart' as persistence;
import '../application/sync_queue_service.dart' as app;

final class IsarSyncQueueStore implements app.SyncQueueStore {
  const IsarSyncQueueStore(this._db);

  final LocalDatabase _db;

  @override
  Future<Result<app.SyncJob>> enqueue(app.SyncJob job) async {
    try {
      final entity = _toEntity(job);
      await _db.isar.writeTxn(() async {
        job.id = await _db.syncQueue.put(entity);
      });
      return Result.success(job);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Der Sync-Job konnte nicht in die Warteschlange eingereiht werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<app.SyncJob>>> getPendingJobs({
    required DateTime now,
    required DateTime staleRunningBefore,
    required int maxAttempts,
  }) async {
    final result = await getAllJobs();
    if (result case Failure<List<app.SyncJob>>(:final failure)) {
      return Result.failure(failure);
    }
    return Result.success(
      result.valueOrNull!.where((job) {
        final retryable =
            job.status == app.SyncJobStatus.pending ||
            job.status == app.SyncJobStatus.failed;
        final lastUpdatedAt = job.updatedAt ?? job.createdAt;
        final stale =
            job.status == app.SyncJobStatus.running &&
            !lastUpdatedAt.isAfter(staleRunningBefore);
        final due = job.nextRetryAt == null || !job.nextRetryAt!.isAfter(now);
        return job.attemptCount < maxAttempts && ((retryable && due) || stale);
      }).toList(),
    );
  }

  @override
  Future<Result<void>> updateJob(app.SyncJob job) async {
    try {
      await _db.isar.writeTxn(() => _db.syncQueue.put(_toEntity(job)));
      return const Result.success(null);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Sync-Job-Status konnte nicht aktualisiert werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteJob(int id) async {
    try {
      await _db.isar.writeTxn(() => _db.syncQueue.delete(id));
      return const Result.success(null);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Sync-Job konnte nicht entfernt werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<app.SyncJob>>> getAllJobs() async {
    try {
      final entities = await _db.syncQueue.where().findAll();
      final jobs = entities.map(_fromEntity).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Result.success(jobs);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Warteschlange konnte nicht gelesen werden.',
          cause: error,
        ),
      );
    }
  }
}

persistence.IsarSyncJob _toEntity(app.SyncJob job) => persistence.IsarSyncJob()
  ..id = job.id
  ..clientId = job.clientId
  ..payload = job.payload
  ..status = persistence.SyncJobStatus.values.byName(job.status.name)
  ..attemptCount = job.attemptCount
  ..nextRetryAt = job.nextRetryAt
  ..errorReason = job.errorReason
  ..createdAt = job.createdAt
  ..updatedAt = job.updatedAt;

app.SyncJob _fromEntity(persistence.IsarSyncJob entity) => app.SyncJob()
  ..id = entity.id
  ..clientId = entity.clientId
  ..payload = entity.payload
  ..status = app.SyncJobStatus.values.byName(entity.status.name)
  ..attemptCount = entity.attemptCount
  ..nextRetryAt = entity.nextRetryAt
  ..errorReason = entity.errorReason
  ..createdAt = entity.createdAt
  ..updatedAt = entity.updatedAt;
