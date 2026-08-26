import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/core/errors/app_failure.dart';
import 'package:plantini_app/core/ids/client_id_generator.dart';
import 'package:plantini_app/core/result.dart';
import 'package:plantini_app/core/time/clock.dart';
import 'package:plantini_app/features/learning/application/learning_session_service.dart';
import 'package:plantini_app/features/learning/domain/learning_models.dart';
import 'package:plantini_app/features/learning/domain/learning_repository.dart';
import 'package:plantini_app/features/learning/domain/quiz_schema_validator.dart';

final class FixedClock implements Clock {
  FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

final class SequentialIdGenerator implements ClientIdGenerator {
  int _counter = 0;
  @override
  String next() => '00000000-0000-4000-8000-${(++_counter).toString().padLeft(12, '0')}';
}

final class InMemoryLearningStore implements LearningSessionStore {
  final Map<String, LearningSession> _storage = {};

  @override
  Future<Result<void>> delete(String levelId) async {
    _storage.remove(levelId);
    return const Result.success(null);
  }

  @override
  Future<Result<LearningSession?>> read(String levelId) async {
    return Result.success(_storage[levelId]);
  }

  @override
  Future<Result<void>> save(LearningSession session) async {
    _storage[session.levelId] = session;
    return const Result.success(null);
  }
}

final class MockLearningRepository implements LearningRepository {
  List<QuizItem> quizItemsToReturn = [];
  bool startAttemptSuccess = true;
  bool completeAttemptSuccess = true;

  @override
  Future<Result<LevelAttempt>> startLevelAttempt({
    required String levelId,
    required String clientAttemptId,
    required String contentVersion,
    required String idempotencyKey,
  }) async {
    if (!startAttemptSuccess) {
      return const Result.failure(ServerFailure(statusCode: 500, message: 'Server error'));
    }
    return Result.success(
      LevelAttempt(
        id: 'server-attempt-001',
        levelId: levelId,
        contentVersion: contentVersion,
        status: LevelAttemptStatus.active,
        startedAt: DateTime.parse('2026-08-25T10:00:00.000Z'),
      ),
    );
  }

  @override
  Future<Result<List<QuizItem>>> listQuizItems({
    required String levelId,
    required String contentVersion,
  }) async {
    return Result.success(quizItemsToReturn);
  }

  @override
  Future<Result<EventBatchAcknowledgement>> submitEvents({
    required List<LearningEvent> events,
    required String idempotencyKey,
  }) async {
    return Result.success(
      EventBatchAcknowledgement(
        acceptedClientEventIds: events.map((e) => e.clientEventId).toList(),
        rejectedCodes: const {},
      ),
    );
  }

  @override
  Future<Result<LevelCompletion>> completeLevelAttempt({
    required String attemptId,
    required String clientEventId,
    required List<QuizAnswer> answers,
    required String idempotencyKey,
  }) async {
    if (!completeAttemptSuccess) {
      return const Result.failure(ServerFailure(statusCode: 500, message: 'Complete error'));
    }
    return Result.success(
      LevelCompletion(
        attemptId: attemptId,
        passed: true,
        score: 1.0,
        status: CompletionStatus.completed,
        progress: ProgressSnapshot(
          updatedAt: DateTime.parse('2026-08-25T10:05:00.000Z'),
          levels: const [],
        ),
      ),
    );
  }

  @override
  Future<Result<ProgressSnapshot>> getProgress({DateTime? since}) async {
    return Result.success(
      ProgressSnapshot(
        updatedAt: DateTime.parse('2026-08-25T10:00:00.000Z'),
        levels: const [],
      ),
    );
  }
}

void main() {
  group('QuizSchemaValidator', () {
    const validator = QuizSchemaValidator();

    test('accepts valid multiple choice quiz items', () {
      final items = [
        const QuizItem(
          id: 'q1',
          levelId: 'l1',
          contentVersion: 'v1',
          type: QuizItemType.multipleChoice,
          prompt: 'Welche Pflanzenart ist das?',
          choices: [
            QuizChoice(id: 'c1', label: 'Eiche'),
            QuizChoice(id: 'c2', label: 'Buche'),
          ],
        ),
      ];
      final res = validator.validate(items);
      expect(res.isSuccess, isTrue);
    });

    test('rejects items with missing prompt or empty choices', () {
      final invalidPrompt = [
        const QuizItem(
          id: 'q1',
          levelId: 'l1',
          contentVersion: 'v1',
          type: QuizItemType.multipleChoice,
          prompt: '',
          choices: [QuizChoice(id: 'c1', label: 'Eiche')],
        ),
      ];
      expect(validator.validate(invalidPrompt).isFailure, isTrue);

      final emptyChoices = [
        const QuizItem(
          id: 'q1',
          levelId: 'l1',
          contentVersion: 'v1',
          type: QuizItemType.multipleChoice,
          prompt: 'Frage',
          choices: [],
        ),
      ];
      expect(validator.validate(emptyChoices).isFailure, isTrue);
    });
  });

  group('LearningSessionService', () {
    late MockLearningRepository repo;
    late InMemoryLearningStore store;
    late LearningSessionService service;
    final fixedTime = DateTime.parse('2026-08-25T10:00:00.000Z');

    final testQuizItems = [
      const QuizItem(
        id: 'q1',
        levelId: 'level-1',
        contentVersion: 'release-1',
        type: QuizItemType.multipleChoice,
        prompt: 'Frage 1',
        choices: [
          QuizChoice(id: 'c1', label: 'A'),
          QuizChoice(id: 'c2', label: 'B'),
        ],
      ),
      const QuizItem(
        id: 'q2',
        levelId: 'level-1',
        contentVersion: 'release-1',
        type: QuizItemType.multipleChoice,
        prompt: 'Frage 2',
        choices: [
          QuizChoice(id: 'c3', label: 'C'),
          QuizChoice(id: 'c4', label: 'D'),
        ],
      ),
    ];

    setUp(() {
      repo = MockLearningRepository()..quizItemsToReturn = testQuizItems;
      store = InMemoryLearningStore();
      service = LearningSessionService(
        repository: repo,
        store: store,
        ids: SequentialIdGenerator(),
        clock: FixedClock(fixedTime),
      );
    });

    test('beginOrResume creates session and saves it locally', () async {
      final result = await service.beginOrResume(
        levelId: 'level-1',
        contentVersion: 'release-1',
      );
      expect(result.isSuccess, isTrue);
      final session = (result as Success<LearningSession>).value;
      expect(session.levelId, 'level-1');
      expect(session.serverAttemptId, 'server-attempt-001');
      expect(session.quizItems.length, 2);

      // Resume returns existing session without calling start again
      final resumed = await service.beginOrResume(
        levelId: 'level-1',
        contentVersion: 'release-1',
      );
      expect((resumed as Success<LearningSession>).value.clientAttemptId, session.clientAttemptId);
    });

    test('recordAnswer updates answers, advances question and completes level', () async {
      final beginRes = await service.beginOrResume(
        levelId: 'level-1',
        contentVersion: 'release-1',
      );
      var session = (beginRes as Success<LearningSession>).value;

      // Answer question 1
      final ans1Res = await service.recordAnswer(
        session: session,
        quizItemId: 'q1',
        choiceId: 'c1',
      );
      expect(ans1Res.isSuccess, isTrue);
      session = (ans1Res as Success<LearningSession>).value;
      expect(session.answers.containsKey('q1'), isTrue);
      expect(session.currentQuestionIndex, 1);

      // Answer question 2
      final ans2Res = await service.recordAnswer(
        session: session,
        quizItemId: 'q2',
        choiceId: 'c3',
      );
      expect(ans2Res.isSuccess, isTrue);
      session = (ans2Res as Success<LearningSession>).value;
      expect(session.answers.length, 2);

      // Complete attempt
      final completeRes = await service.complete(session);
      expect(completeRes.isSuccess, isTrue);
      final completion = (completeRes as Success<LevelCompletion>).value;
      expect(completion.passed, isTrue);
      expect(completion.score, 1.0);
    });
  });
}
