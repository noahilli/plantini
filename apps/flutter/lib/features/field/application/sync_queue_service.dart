import 'dart:math';

import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/time/clock.dart';

enum SyncJobStatus { pending, running, failed, completed }

final class SyncJob {
  int id = -1;
  late String clientId;
  late String payload;
  late SyncJobStatus status;
  int attemptCount = 0;
  DateTime? nextRetryAt;
  String? errorReason;
  late DateTime createdAt;
  DateTime? updatedAt;
}

/// Processor callback representing the remote API call / identification execution.
typedef SyncJobProcessor = Future<Result<void>> Function(String payload);

/// Storage abstraction for synchronization queue operations.
abstract interface class SyncQueueStore {
  Future<Result<SyncJob>> enqueue(SyncJob job);
  Future<Result<List<SyncJob>>> getPendingJobs({
    required DateTime now,
    required DateTime staleRunningBefore,
    required int maxAttempts,
  });
  Future<Result<void>> updateJob(SyncJob job);
  Future<Result<void>> deleteJob(int id);
  Future<Result<List<SyncJob>>> getAllJobs();
}

/// In-memory queue store for unit testing.
final class InMemorySyncQueueStore implements SyncQueueStore {
  final Map<int, SyncJob> _storage = {};
  int _autoId = 0;

  @override
  Future<Result<SyncJob>> enqueue(SyncJob job) async {
    final existing = _storage.values.where(
      (item) => item.clientId == job.clientId,
    );
    if (existing.isNotEmpty) {
      job.id = existing.first.id;
    }
    if (job.id <= 0) {
      job.id = ++_autoId;
    }
    _storage[job.id] = job;
    return Result.success(job);
  }

  @override
  Future<Result<List<SyncJob>>> getPendingJobs({
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
      final isDue = job.nextRetryAt == null || !job.nextRetryAt!.isAfter(now);
      return job.attemptCount < maxAttempts &&
          ((isPendingOrFailed && isDue) || isStaleRunning);
    }).toList();
    jobs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return Result.success(jobs);
  }

  @override
  Future<Result<void>> updateJob(SyncJob job) async {
    _storage[job.id] = job;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteJob(int id) async {
    _storage.remove(id);
    return const Result.success(null);
  }

  @override
  Future<Result<List<SyncJob>>> getAllJobs() async {
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
  Future<Result<SyncJob>> enqueueJob({
    required String payload,
    String? clientId,
  }) async {
    final now = _clock.now();
    final job = SyncJob()
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
    if (pendingResult case Failure<List<SyncJob>>(:final failure)) {
      return Result.failure(failure);
    }

    final jobs = (pendingResult as Success<List<SyncJob>>).value;
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

  /// Explicit user retry. Exhausted jobs are re-armed without changing their
  /// stable client IDs, so the remote idempotency contract still applies.
  Future<Result<int>> retryFailedJobs() async {
    final result = await store.getAllJobs();
    if (result case Failure<List<SyncJob>>(:final failure)) {
      return Result.failure(failure);
    }
    var count = 0;
    for (final job in (result as Success<List<SyncJob>>).value) {
      if (job.status != SyncJobStatus.failed) continue;
      job
        ..status = SyncJobStatus.pending
        ..attemptCount = 0
        ..nextRetryAt = _clock.now()
        ..updatedAt = _clock.now();
      await store.updateJob(job);
      count++;
    }
    return Result.success(count);
  }
}
