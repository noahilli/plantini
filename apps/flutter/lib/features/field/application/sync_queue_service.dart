import 'dart:math';

import 'package:isar/isar.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/storage/models/isar_sync_queue.dart';
import '../../../core/time/clock.dart';

/// Processor callback representing the remote API call / identification execution.
typedef SyncJobProcessor = Future<Result<void>> Function(String payload);

/// Storage abstraction for synchronization queue operations.
abstract interface class SyncQueueStore {
  Future<Result<IsarSyncJob>> enqueue(IsarSyncJob job);
  Future<Result<List<IsarSyncJob>>> getPendingJobs({
    required DateTime now,
    required DateTime staleRunningBefore,
    required int maxAttempts,
  });
  Future<Result<void>> updateJob(IsarSyncJob job);
  Future<Result<void>> deleteJob(int id);
  Future<Result<List<IsarSyncJob>>> getAllJobs();
}

/// Isar-backed implementation of [SyncQueueStore].
final class IsarSyncQueueStore implements SyncQueueStore {
  const IsarSyncQueueStore(this._db);

  final LocalDatabase _db;

  @override
  Future<Result<IsarSyncJob>> enqueue(IsarSyncJob job) async {
    try {
      await _db.isar.writeTxn(() async {
        await _db.syncQueue.put(job);
      });
      return Result.success(job);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message:
              'Der Sync-Job konnte nicht in die Warteschlange eingereiht werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<IsarSyncJob>>> getPendingJobs({
    required DateTime now,
    required DateTime staleRunningBefore,
    required int maxAttempts,
  }) async {
    try {
      final all = await _db.syncQueue.where().findAll();
      all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final due = all.where((job) {
        final isPendingOrFailed =
            job.status == SyncJobStatus.pending ||
            job.status == SyncJobStatus.failed;
        final lastUpdatedAt = job.updatedAt ?? job.createdAt;
        final isStaleRunning =
            job.status == SyncJobStatus.running &&
            !lastUpdatedAt.isAfter(staleRunningBefore);
        final isDue =
            job.nextRetryAt == null || !job.nextRetryAt!.isAfter(now);
        return job.attemptCount < maxAttempts &&
            ((isPendingOrFailed && isDue) || isStaleRunning);
      }).toList();
      return Result.success(due);
    } catch (error) {
      return Result.failure(
        StorageFailure(
          message: 'Fällige Sync-Jobs konnten nicht geladen werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateJob(IsarSyncJob job) async {
    try {
      await _db.isar.writeTxn(() async {
        await _db.syncQueue.put(job);
      });
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
      await _db.isar.writeTxn(() async {
        await _db.syncQueue.delete(id);
      });
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
  Future<Result<List<IsarSyncJob>>> getAllJobs() async {
    try {
      final jobs = await _db.syncQueue.where().findAll();
      jobs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
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

/// In-memory queue store for unit testing.
final class InMemorySyncQueueStore implements SyncQueueStore {
  final Map<int, IsarSyncJob> _storage = {};
  int _autoId = 0;

  @override
  Future<Result<IsarSyncJob>> enqueue(IsarSyncJob job) async {
    if (job.id == Isar.autoIncrement || job.id <= 0) {
      job.id = ++_autoId;
    }
    _storage[job.id] = job;
    return Result.success(job);
  }

  @override
  Future<Result<List<IsarSyncJob>>> getPendingJobs({
    required DateTime now,
    required DateTime staleRunningBefore,
    required int maxAttempts,
  }) async {
    final jobs = _storage.values.where((job) {
      final isPendingOrFailed =
          job.status == SyncJobStatus.pending ||
          job.status == SyncJobStatus.failed;
      final lastUpdatedAt = job.updatedAt ?? job.createdAt;
      final isStaleRunning =
          job.status == SyncJobStatus.running &&
          !lastUpdatedAt.isAfter(staleRunningBefore);
      final isDue =
          job.nextRetryAt == null || !job.nextRetryAt!.isAfter(now);
      return job.attemptCount < maxAttempts &&
          ((isPendingOrFailed && isDue) || isStaleRunning);
    }).toList();
    jobs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return Result.success(jobs);
  }

  @override
  Future<Result<void>> updateJob(IsarSyncJob job) async {
    _storage[job.id] = job;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteJob(int id) async {
    _storage.remove(id);
    return const Result.success(null);
  }

  @override
  Future<Result<List<IsarSyncJob>>> getAllJobs() async {
    final list = _storage.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return Result.success(list);
  }
}

/// Background synchronization queue service with exponential backoff.
final class SyncQueueService {
  SyncQueueService({
    required this.store,
    this.ids,
    Clock? clock,
    this.baseBackoffSeconds = 2,
    this.maxBackoffSeconds = 300,
    this.maxAttempts = 5,
    this.runningJobTimeout = const Duration(minutes: 5),
  }) : _clock = clock ?? const SystemClock();

  final SyncQueueStore store;
  final ClientIdGenerator? ids;
  final Clock _clock;
  final int baseBackoffSeconds;
  final int maxBackoffSeconds;
  final int maxAttempts;
  final Duration runningJobTimeout;

  /// Enqueues a new synchronization job with status `pending`.
  Future<Result<IsarSyncJob>> enqueueJob({
    required String payload,
    String? clientId,
  }) async {
    final now = _clock.now();
    final job = IsarSyncJob()
      ..clientId =
          clientId ?? ids?.next() ?? 'job-${now.millisecondsSinceEpoch}'
      ..payload = payload
      ..status = SyncJobStatus.pending
      ..attemptCount = 0
      ..nextRetryAt = now
      ..createdAt = now
      ..updatedAt = now;

    return store.enqueue(job);
  }

  /// Calculates exponential backoff duration based on attempt count.
  /// Formula: min(maxBackoff, baseBackoff * 2^(attemptCount - 1))
  Duration calculateBackoff(int attemptCount) {
    if (attemptCount <= 0) return Duration.zero;
    final exponential = baseBackoffSeconds * pow(2, attemptCount - 1).toInt();
    final delaySeconds = min(maxBackoffSeconds, exponential);
    return Duration(seconds: delaySeconds);
  }

  /// Processes all pending and due failed jobs in the queue.
  Future<Result<int>> processQueue({
    required SyncJobProcessor processor,
  }) async {
    final now = _clock.now();
    final pendingResult = await store.getPendingJobs(
      now: now,
      staleRunningBefore: now.subtract(runningJobTimeout),
      maxAttempts: maxAttempts,
    );
    if (pendingResult case Failure<List<IsarSyncJob>>(:final failure)) {
      return Result.failure(failure);
    }

    final jobs = (pendingResult as Success<List<IsarSyncJob>>).value;
    var processedCount = 0;

    for (final job in jobs) {
      job.status = SyncJobStatus.running;
      job.attemptCount += 1;
      job.updatedAt = _clock.now();
      await store.updateJob(job);

      final result = await processor(job.payload);

      if (result.isSuccess) {
        job.status = SyncJobStatus.completed;
        job.errorReason = null;
        job.updatedAt = _clock.now();
        await store.updateJob(job);
        processedCount++;
      } else {
        final failure = result.failureOrNull;
        job.errorReason =
            failure?.message ?? 'Unbekannter Synchronisationsfehler';
        job.status = SyncJobStatus.failed;

        final backoff = calculateBackoff(job.attemptCount);
        job.nextRetryAt = _clock.now().add(backoff);
        job.updatedAt = _clock.now();

        await store.updateJob(job);
      }
    }

    return Result.success(processedCount);
  }

  /// Connectivity trigger to process due queue items when network returns.
  Future<Result<int>> onNetworkRestored({
    required SyncJobProcessor processor,
  }) async {
    return processQueue(processor: processor);
  }
}
