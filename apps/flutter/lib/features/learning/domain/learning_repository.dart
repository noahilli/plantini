import '../../../core/result.dart';
import 'learning_models.dart';

abstract interface class LearningRepository {
  Future<Result<List<QuizItem>>> listQuizItems({
    required String levelId,
    required String contentVersion,
  });

  Future<Result<LevelAttempt>> startLevelAttempt({
    required String levelId,
    required String clientAttemptId,
    required String contentVersion,
    required String idempotencyKey,
  });

  Future<Result<EventBatchAcknowledgement>> submitEvents({
    required List<LearningEvent> events,
    required String idempotencyKey,
  });

  Future<Result<LevelCompletion>> completeLevelAttempt({
    required String attemptId,
    required String clientEventId,
    required List<QuizAnswer> answers,
    required String idempotencyKey,
  });

  Future<Result<ProgressSnapshot>> getProgress({DateTime? since});
}

abstract interface class LearningSessionStore {
  Future<Result<LearningSession?>> read(String levelId);
  Future<Result<void>> save(LearningSession session);
  Future<Result<void>> delete(String levelId);
}
