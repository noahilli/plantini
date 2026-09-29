import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for LearningApi
void main() {
  final instance = Openapi().getLearningApi();

  group(LearningApi, () {
    // Complete an attempt with server-side scoring
    //
    //Future<LevelCompletion> completeLevelAttempt(String attemptId, String idempotencyKey, CompleteLevelAttemptRequest completeLevelAttemptRequest) async
    test('test completeLevelAttempt', () async {
      // TODO
    });

    // Compute the actor's ecosystem completion from passed levels and collected species
    //
    // Read-only authoritative snapshot. Collection can precede any quiz. All quiz levels remain passable without collection when collectionScope is ecosystem. A deleted herbarium record no longer counts; duplicates and foreign species do not satisfy additional targets. No completion mutation is required.
    //
    //Future<EcosystemProgress> getEcosystemProgress(String ecosystemId) async
    test('test getEcosystemProgress', () async {
      // TODO
    });

    // Read server-authoritative learning progress
    //
    //Future<ProgressSnapshot> getProgress({ DateTime since }) async
    test('test getProgress', () async {
      // TODO
    });

    // List earned and next learning achievements
    //
    //Future<AchievementPage> listAchievements() async
    test('test listAchievements', () async {
      // TODO
    });

    // List quiz items for a level and content version
    //
    //Future<QuizItemPage> listQuizItems(String levelId, { String contentVersion }) async
    test('test listQuizItems', () async {
      // TODO
    });

    // Start or resume an idempotent level attempt
    //
    // Missing requiredLevelIds returns 409 LEVEL_LOCKED. Passed levels permit revisits; failed attempts can be retried using a new clientAttemptId.
    //
    //Future<LevelAttempt> startLevelAttempt(String idempotencyKey, StartLevelAttemptRequest startLevelAttemptRequest) async
    test('test startLevelAttempt', () async {
      // TODO
    });

    // Submit idempotent offline learning events
    //
    //Future<EventBatchAck> submitLearningEvents(String idempotencyKey, LearningEventBatch learningEventBatch) async
    test('test submitLearningEvents', () async {
      // TODO
    });

    // Synchronize a bounded offline event batch and progress cursor
    //
    //Future<SyncResponse> synchronize(String idempotencyKey, SyncRequest syncRequest) async
    test('test synchronize', () async {
      // TODO
    });
  });
}
