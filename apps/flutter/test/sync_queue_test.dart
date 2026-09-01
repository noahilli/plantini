import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/ids/client_id_generator.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/core/time/clock.dart';
import 'package:plantini_app/features/field/application/sync_queue_service.dart';

final class TestClock implements Clock {
  TestClock(this._now);
  DateTime _now;
  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}

final class TestIdGenerator implements ClientIdGenerator {
  int _counter = 0;
  @override
  String next() => 'sync-id-${++_counter}';
}

void main() {
  group('SyncQueueService', () {
    late InMemorySyncQueueStore store;
    late TestClock clock;
    late TestIdGenerator ids;
    late SyncQueueService service;
    final initialTime = DateTime.parse('2026-08-26T14:00:00Z');

    setUp(() {
      store = InMemorySyncQueueStore();
      clock = TestClock(initialTime);
      ids = TestIdGenerator();
      service = SyncQueueService(
        store: store,
        ids: ids,
        clock: clock,
        baseBackoffSeconds: 2,
        maxBackoffSeconds: 30,
      );
    });

    test(
      'enqueueJob creates pending job with immediate retry schedule',
      () async {
        final result = await service.enqueueJob(
          payload: '{"observationId": "obs-1"}',
        );

        expect(result.isSuccess, isTrue);
        final job = (result as Success<SyncJob>).value;
        expect(job.status, SyncJobStatus.pending);
        expect(job.clientId, 'sync-id-1');
        expect(job.attemptCount, 0);
        expect(job.payload, '{"observationId": "obs-1"}');
        expect(job.nextRetryAt, initialTime);
      },
    );

    test('processQueue completes jobs when processor succeeds', () async {
      await service.enqueueJob(payload: 'job-1');
      await service.enqueueJob(payload: 'job-2');

      final processedPayloads = <String>[];
      final processResult = await service.processQueue(
        processor: (payload) async {
          processedPayloads.add(payload);
          return const Result.success(null);
        },
      );

      expect(processResult.isSuccess, isTrue);
      expect((processResult as Success<int>).value, 2);
      expect(processedPayloads, ['job-1', 'job-2']);

      final allJobsResult = await store.getAllJobs();
      final jobs = (allJobsResult as Success<List<SyncJob>>).value;
      expect(jobs.every((j) => j.status == SyncJobStatus.completed), isTrue);
    });

    test('processQueue increments attemptCount and schedules exponential backoff on failure', () async {
      await service.enqueueJob(payload: 'flaky-job');

      // Attempt 1: fails -> backoff: 2 * 2^0 = 2 seconds
      final failResult = await service.processQueue(
        processor: (payload) async =>
            const Result.failure(NetworkFailure(message: 'Server unreachable')),
      );

      expect(failResult.isSuccess, isTrue);
      expect((failResult as Success<int>).value, 0);

      var jobs = (await store.getAllJobs() as Success<List<SyncJob>>).value;
      expect(jobs.first.status, SyncJobStatus.failed);
      expect(jobs.first.attemptCount, 1);
      expect(jobs.first.errorReason, 'Server unreachable');
      expect(
        jobs.first.nextRetryAt,
        initialTime.add(const Duration(seconds: 2)),
      );

      // Queue process before due time: should not process flaky-job
      clock.advance(const Duration(seconds: 1));
      var secondRun = await service.processQueue(
        processor: (_) async => const Result.success(null),
      );
      expect((secondRun as Success<int>).value, 0);

      // Advance past retry time: attempt 2 fails -> backoff: 2 * 2^1 = 4 seconds
      clock.advance(const Duration(seconds: 2));
      await service.processQueue(
        processor: (payload) async =>
            const Result.failure(NetworkFailure(message: 'Server still down')),
      );

      jobs = (await store.getAllJobs() as Success<List<SyncJob>>).value;
      expect(jobs.first.attemptCount, 2);
      expect(jobs.first.errorReason, 'Server still down');
      expect(
        jobs.first.nextRetryAt,
        clock.now().add(const Duration(seconds: 4)),
      );
    });

    test('calculateBackoff respects max backoff ceiling', () {
      expect(service.calculateBackoff(0), Duration.zero);
      expect(service.calculateBackoff(1), const Duration(seconds: 2));
      expect(service.calculateBackoff(2), const Duration(seconds: 4));
      expect(service.calculateBackoff(3), const Duration(seconds: 8));
      expect(service.calculateBackoff(4), const Duration(seconds: 16));
      expect(
        service.calculateBackoff(5),
        const Duration(seconds: 30),
      ); // Capped at maxBackoffSeconds (30)
      expect(service.calculateBackoff(10), const Duration(seconds: 30));
    });

    test('onNetworkRestored triggers queue processing', () async {
      await service.enqueueJob(payload: 'offline-observation');

      final processed = <String>[];
      final result = await service.onNetworkRestored(
        processor: (payload) async {
          processed.add(payload);
          return const Result.success(null);
        },
      );

      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, 1);
      expect(processed, ['offline-observation']);
    });

    test(
      'processQueue recovers a running job after its lease becomes stale',
      () async {
        final job = SyncJob()
          ..clientId = 'interrupted-job'
          ..payload = 'interrupted-payload'
          ..status = SyncJobStatus.running
          ..attemptCount = 1
          ..nextRetryAt = initialTime
          ..createdAt = initialTime
          ..updatedAt = initialTime;
        await store.enqueue(job);

        clock.advance(const Duration(minutes: 4));
        var processorCalls = 0;
        await service.processQueue(
          processor: (_) async {
            processorCalls++;
            return const Result.success(null);
          },
        );
        expect(processorCalls, 0);

        clock.advance(const Duration(minutes: 1));
        final result = await service.processQueue(
          processor: (_) async {
            processorCalls++;
            return const Result.success(null);
          },
        );

        expect((result as Success<int>).value, 1);
        expect(processorCalls, 1);
        final jobs = (await store.getAllJobs() as Success<List<SyncJob>>).value;
        expect(jobs.single.status, SyncJobStatus.completed);
        expect(jobs.single.attemptCount, 2);
      },
    );

    test(
      'processQueue never dispatches a job that exhausted maxAttempts',
      () async {
        service = SyncQueueService(
          store: store,
          ids: ids,
          clock: clock,
          maxAttempts: 2,
        );
        final job = SyncJob()
          ..clientId = 'exhausted-job'
          ..payload = 'must-not-run'
          ..status = SyncJobStatus.failed
          ..attemptCount = 2
          ..nextRetryAt = initialTime
          ..createdAt = initialTime
          ..updatedAt = initialTime;
        await store.enqueue(job);

        var processorCalls = 0;
        final result = await service.processQueue(
          processor: (_) async {
            processorCalls++;
            return const Result.success(null);
          },
        );

        expect((result as Success<int>).value, 0);
        expect(processorCalls, 0);
        final jobs = (await store.getAllJobs() as Success<List<SyncJob>>).value;
        expect(jobs.single.status, SyncJobStatus.failed);
        expect(jobs.single.attemptCount, 2);
      },
    );

    test(
      'manual retry rearms an exhausted job with the same client id',
      () async {
        final job = SyncJob()
          ..clientId = 'stable-observation-id'
          ..payload = 'retry-payload'
          ..status = SyncJobStatus.failed
          ..attemptCount = 5
          ..errorReason = 'offline'
          ..nextRetryAt = initialTime
          ..createdAt = initialTime
          ..updatedAt = initialTime;
        await store.enqueue(job);

        final retried = await service.retryFailedJobs();
        final jobs = (await store.getAllJobs()).valueOrNull!;

        expect(retried.valueOrNull, 1);
        expect(jobs.single.clientId, 'stable-observation-id');
        expect(jobs.single.status, SyncJobStatus.pending);
        expect(jobs.single.attemptCount, 0);
      },
    );
  });
}
