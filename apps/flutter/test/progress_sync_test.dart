import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/ids/client_id_generator.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/core/time/clock.dart';
import 'package:plantini_app/features/learning/application/progress_sync_service.dart';
import 'package:plantini_app/features/learning/domain/learning_models.dart';
import 'package:plantini_app/features/learning/domain/learning_repository.dart';

final class MockLearningRepository implements LearningRepository {
  ProgressSnapshot? progressToReturn;
  bool submitEventsSuccess = true;
  List<LearningEvent> receivedEvents = [];

  @override
  Future<Result<EventBatchAcknowledgement>> submitEvents({
    required List<LearningEvent> events,
    required String idempotencyKey,
  }) async {
    if (!submitEventsSuccess) {
      return const Result.failure(
        ServerFailure(statusCode: 500, message: 'Submit failed'),
      );
    }
    receivedEvents.addAll(events);
    return Result.success(
      EventBatchAcknowledgement(
        acceptedClientEventIds: events.map((e) => e.clientEventId).toList(),
        rejectedCodes: const {},
      ),
    );
  }

  @override
  Future<Result<ProgressSnapshot>> getProgress({DateTime? since}) async {
    return Result.success(
      progressToReturn ??
          ProgressSnapshot(
            updatedAt: DateTime.parse('2026-08-26T12:00:00Z'),
            levels: const [
              LevelProgressSnapshot(
                levelId: 'level-1',
                status: ProgressStatus.completed,
                percentage: 1.0,
              ),
            ],
          ),
    );
  }

  @override
  Future<Result<LevelCompletion>> completeLevelAttempt({
    required String attemptId,
    required String clientEventId,
    required List<QuizAnswer> answers,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<QuizItem>>> listQuizItems({
    required String levelId,
    required String contentVersion,
  }) async => throw UnimplementedError();

  @override
  Future<Result<LevelAttempt>> startLevelAttempt({
    required String levelId,
    required String clientAttemptId,
    required String contentVersion,
    required String idempotencyKey,
  }) async => throw UnimplementedError();
}

final class FixedClock implements Clock {
  FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

final class FixedIdGenerator implements ClientIdGenerator {
  @override
  String next() => 'id-fixed-001';
}

void main() {
  group('ProgressSyncService', () {
    late MockLearningRepository repo;
    late InMemoryProgressStore store;
    late ProgressSyncService service;
    final testTime = DateTime.parse('2026-08-26T14:00:00Z');

    setUp(() {
      repo = MockLearningRepository();
      store = InMemoryProgressStore();
      service = ProgressSyncService(
        repository: repo,
        store: store,
        ids: FixedIdGenerator(),
        clock: FixedClock(testTime),
      );
    });

    test('synchronize submits pending events and stores merged progress', () async {
      final initialLocalSnapshot = ProgressSnapshot(
        updatedAt: DateTime.parse('2026-08-26T10:00:00Z'),
        levels: const [
          LevelProgressSnapshot(
            levelId: 'level-0',
            status: ProgressStatus.completed,
            percentage: 1.0,
          ),
        ],
      );
      await store.save(initialLocalSnapshot);

      final event = LearningEvent(
        clientEventId: 'event-1',
        type: 'quiz_answered',
        occurredAt: testTime,
        payloadVersion: 1,
        payload: {'levelId': 'level-1'},
      );

      final result = await service.synchronize(
        pendingEvents: [event],
      );

      expect(result.isSuccess, isTrue);
      expect(repo.receivedEvents.length, 1);
      expect(repo.receivedEvents.first.clientEventId, 'event-1');

      final progress = (result as Success<ProgressSnapshot>).value;
      expect(progress.levels.length, 2);
      expect(progress.levels.any((l) => l.levelId == 'level-1'), isTrue);
      expect(progress.levels.any((l) => l.levelId == 'level-0'), isTrue);

      final localRead = await service.getLocalProgress();
      expect(localRead.valueOrNull?.levels.length, 2);
    });

    test('mergeProgress resolves conflicts with Server winning', () {
      final serverSnapshot = ProgressSnapshot(
        updatedAt: DateTime.parse('2026-08-26T13:00:00Z'),
        levels: const [
          LevelProgressSnapshot(
            levelId: 'level-1',
            status: ProgressStatus.completed,
            percentage: 1.0,
          ),
          LevelProgressSnapshot(
            levelId: 'level-2',
            status: ProgressStatus.available,
            percentage: 0.0,
          ),
        ],
      );

      final localSnapshot = ProgressSnapshot(
        updatedAt: DateTime.parse('2026-08-26T12:00:00Z'),
        levels: const [
          // Conflict: Local says inProgress 0.5, but Server says completed 1.0
          LevelProgressSnapshot(
            levelId: 'level-1',
            status: ProgressStatus.inProgress,
            percentage: 0.5,
          ),
          // Local-only level
          LevelProgressSnapshot(
            levelId: 'level-offline-only',
            status: ProgressStatus.inProgress,
            percentage: 0.3,
          ),
        ],
      );

      final merged = service.mergeProgress(
        server: serverSnapshot,
        local: localSnapshot,
      );

      expect(merged.levels.length, 3);
      final level1 = merged.levels.firstWhere((l) => l.levelId == 'level-1');
      expect(level1.status, ProgressStatus.completed);
      expect(level1.percentage, 1.0);

      final level2 = merged.levels.firstWhere((l) => l.levelId == 'level-2');
      expect(level2.status, ProgressStatus.available);

      final offlineOnly = merged.levels.firstWhere((l) => l.levelId == 'level-offline-only');
      expect(offlineOnly.status, ProgressStatus.inProgress);
      expect(offlineOnly.percentage, 0.3);
    });

    test('synchronize returns failure when submitEvents fails', () async {
      repo.submitEventsSuccess = false;

      final event = LearningEvent(
        clientEventId: 'event-err',
        type: 'quiz_answered',
        occurredAt: testTime,
        payloadVersion: 1,
        payload: {},
      );

      final result = await service.synchronize(pendingEvents: [event]);
      expect(result.isFailure, isTrue);
    });
  });
}
