import '../../../core/errors/app_failure.dart';
import '../../../core/ids/client_id_generator.dart';
import '../../../core/result.dart';
import '../../../core/time/clock.dart';
import '../domain/learning_models.dart';
import '../domain/learning_repository.dart';
import '../domain/quiz_schema_validator.dart';

/// Coordinates local resume state and the server-authoritative attempt flow.
/// No Flutter, Isar, or HTTP type crosses this application boundary.
final class LearningSessionService {
  LearningSessionService({
    required this._repository,
    required this._store,
    required this._ids,
    required this._clock,
    QuizSchemaValidator? validator,
  }) : _validator = validator ?? const QuizSchemaValidator();

  final LearningRepository _repository;
  final LearningSessionStore _store;
  final ClientIdGenerator _ids;
  final Clock _clock;
  final QuizSchemaValidator _validator;

  Future<Result<LearningSession>> beginOrResume({
    required String levelId,
    required String contentVersion,
  }) async {
    final local = await _store.read(levelId);
    if (local case Failure<LearningSession?>(:final failure)) {
      return Result.failure(failure);
    }
    final existing = (local as Success<LearningSession?>).value;
    if (existing != null && existing.contentVersion == contentVersion) {
      return Result.success(existing);
    }

    final quizItems = await _repository.listQuizItems(
      levelId: levelId,
      contentVersion: contentVersion,
    );
    if (quizItems case Failure<List<QuizItem>>(:final failure)) {
      return Result.failure(failure);
    }
    final validated = _validator.validate(
      (quizItems as Success<List<QuizItem>>).value,
    );
    if (validated case Failure<List<QuizItem>>(:final failure)) {
      return Result.failure(failure);
    }

    final clientAttemptId = _ids.next();
    final attempt = await _repository.startLevelAttempt(
      levelId: levelId,
      clientAttemptId: clientAttemptId,
      contentVersion: contentVersion,
      idempotencyKey: _ids.next(),
    );
    if (attempt case Failure<LevelAttempt>(:final failure)) {
      return Result.failure(failure);
    }

    final session = LearningSession(
      clientAttemptId: clientAttemptId,
      serverAttemptId: (attempt as Success<LevelAttempt>).value.id,
      levelId: levelId,
      contentVersion: contentVersion,
      quizItems: (validated as Success<List<QuizItem>>).value,
      answers: const {},
      pendingEvents: const [],
      currentQuestionIndex: 0,
      updatedAt: _clock.now(),
    );
    final stored = await _store.save(session);
    if (stored case Failure<void>(:final failure)) {
      return Result.failure(failure);
    }
    return Result.success(session);
  }

  Future<Result<LearningSession>> recordAnswer({
    required LearningSession session,
    required String quizItemId,
    required String choiceId,
  }) async {
    QuizItem? item;
    for (final candidate in session.quizItems) {
      if (candidate.id == quizItemId) {
        item = candidate;
        break;
      }
    }
    if (item == null || !item.choices.any((choice) => choice.id == choiceId)) {
      return const Result.failure(
        ValidationFailure(
          message: 'Diese Antwort gehört nicht zu der aktuellen Quizfrage.',
        ),
      );
    }
    final answers = Map<String, QuizAnswer>.from(session.answers)
      ..[quizItemId] = QuizAnswer(quizItemId: quizItemId, choiceId: choiceId);
    final event = LearningEvent(
      clientEventId: _ids.next(),
      type: 'quiz_answered',
      occurredAt: _clock.now(),
      payloadVersion: 1,
      payload: {
        'levelId': session.levelId,
        'quizItemId': quizItemId,
        'choiceId': choiceId,
      },
    );
    final nextIndex =
        session.currentQuestionIndex < session.quizItems.length - 1
        ? session.currentQuestionIndex + 1
        : session.currentQuestionIndex;
    final updated = session.copyWith(
      answers: answers,
      pendingEvents: [...session.pendingEvents, event],
      currentQuestionIndex: nextIndex,
      updatedAt: _clock.now(),
    );
    final stored = await _store.save(updated);
    if (stored case Failure<void>(:final failure)) {
      return Result.failure(failure);
    }
    return Result.success(updated);
  }

  Future<Result<LearningSession>> submitPendingEvents(
    LearningSession session,
  ) async {
    if (session.pendingEvents.isEmpty) return Result.success(session);
    final acknowledgement = await _repository.submitEvents(
      events: session.pendingEvents,
      idempotencyKey: _ids.next(),
    );
    if (acknowledgement case Failure<EventBatchAcknowledgement>(
      :final failure,
    )) {
      return Result.failure(failure);
    }
    final ack = (acknowledgement as Success<EventBatchAcknowledgement>).value;
    if (ack.rejectedCodes.isNotEmpty) {
      return Result.failure(
        ValidationFailure(
          message: 'Der Server hat mindestens ein Lernereignis abgelehnt.',
          fieldErrors: ack.rejectedCodes,
        ),
      );
    }
    final accepted = ack.acceptedClientEventIds.toSet();
    final updated = session.copyWith(
      pendingEvents: session.pendingEvents
          .where((event) => !accepted.contains(event.clientEventId))
          .toList(growable: false),
      updatedAt: _clock.now(),
    );
    final stored = await _store.save(updated);
    if (stored case Failure<void>(:final failure)) {
      return Result.failure(failure);
    }
    return Result.success(updated);
  }

  Future<Result<LevelCompletion>> complete(LearningSession session) async {
    final synced = await submitPendingEvents(session);
    if (synced case Failure<LearningSession>(:final failure)) {
      if (failure.isRetryable) {
        await _store.save(
          session.copyWith(completionPending: true, updatedAt: _clock.now()),
        );
      }
      return Result.failure(failure);
    }
    final ready = (synced as Success<LearningSession>).value;
    if (ready.serverAttemptId == null) {
      return const Result.failure(
        ConflictFailure(
          message:
              'Der lokale Lernversuch besitzt keine serverseitige Attempt-ID.',
        ),
      );
    }
    if (ready.answers.length != ready.quizItems.length) {
      return const Result.failure(
        ValidationFailure(message: 'Beantworte zuerst alle Quizfragen.'),
      );
    }
    final completion = await _repository.completeLevelAttempt(
      attemptId: ready.serverAttemptId!,
      clientEventId: _ids.next(),
      answers: ready.answers.values.toList(growable: false),
      idempotencyKey: _ids.next(),
    );
    if (completion case Failure<LevelCompletion>(:final failure)) {
      final pending = ready.copyWith(completionPending: failure.isRetryable);
      await _store.save(pending);
      return Result.failure(failure);
    }
    await _store.delete(ready.levelId);
    return completion;
  }
}
