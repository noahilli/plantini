import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/learning_models.dart';
import '../domain/learning_repository.dart';

/// HTTP adapter for the v1 learning contract. Answer keys are never mapped on
/// the client; the completion response is the sole scoring authority.
final class HttpLearningRepository implements LearningRepository {
  const HttpLearningRepository(this._client);

  final PlatformApiClient _client;

  @override
  Future<Result<List<QuizItem>>> listQuizItems({
    required String levelId,
    required String contentVersion,
  }) async {
    final response = await _client.getJson(
      'quiz-items',
      queryParameters: {'levelId': levelId, 'contentVersion': contentVersion},
      requiresAuthentication: true,
    );
    return response.when(
      success: (value) => _quizItems(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<LevelAttempt>> startLevelAttempt({
    required String levelId,
    required String clientAttemptId,
    required String contentVersion,
    required String idempotencyKey,
  }) async {
    final response = await _client.postJson(
      'level-attempts',
      idempotencyKey: idempotencyKey,
      body: {
        'levelId': levelId,
        'clientAttemptId': clientAttemptId,
        'contentVersion': contentVersion,
      },
    );
    return response.when(
      success: (value) => _attempt(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<EventBatchAcknowledgement>> submitEvents({
    required List<LearningEvent> events,
    required String idempotencyKey,
  }) async {
    final response = await _client.postJson(
      'learning-events/batch',
      idempotencyKey: idempotencyKey,
      body: {
        'events': events.map((event) => event.toJson()).toList(growable: false),
      },
    );
    return response.when(
      success: (value) => _eventAcknowledgement(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<LevelCompletion>> completeLevelAttempt({
    required String attemptId,
    required String clientEventId,
    required List<QuizAnswer> answers,
    required String idempotencyKey,
  }) async {
    final response = await _client.postJson(
      'level-attempts/$attemptId/complete',
      idempotencyKey: idempotencyKey,
      body: {
        'clientEventId': clientEventId,
        'answers': answers
            .map((answer) => answer.toJson())
            .toList(growable: false),
      },
    );
    return response.when(
      success: (value) => _completion(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<ProgressSnapshot>> getProgress({DateTime? since}) async {
    final response = await _client.getJson(
      'progress',
      queryParameters: {
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
      requiresAuthentication: true,
    );
    return response.when(
      success: (value) => _progress(value.body),
      failure: Result.failure,
    );
  }
}

Result<List<QuizItem>> _quizItems(Map<String, dynamic> body) {
  final raw = body['items'];
  if (raw is! List) {
    return _missing('Quiz-Items benötigen ein items-Array.', ['items']);
  }
  final items = <QuizItem>[];
  for (var index = 0; index < raw.length; index++) {
    final value = raw[index];
    if (value is! Map<String, dynamic>) {
      return _missing('Ein Quiz-Item ist kein Objekt.', ['items[$index]']);
    }
    final parsed = _quizItem(value);
    if (parsed case Failure<QuizItem>(:final failure)) {
      return Result.failure(failure);
    }
    items.add((parsed as Success<QuizItem>).value);
  }
  return Result.success(items);
}

Result<QuizItem> _quizItem(Map<String, dynamic> value) {
  final id = _string(value, 'id');
  final levelId = _string(value, 'levelId');
  final contentVersion = _string(value, 'contentVersion');
  final prompt = _string(value, 'prompt');
  final type = _quizType(value['type']);
  if (id == null ||
      levelId == null ||
      contentVersion == null ||
      prompt == null ||
      type == null) {
    return _missing('Ein Quiz-Item enthält unvollständige Pflichtfelder.', [
      'id',
      'levelId',
      'contentVersion',
      'prompt',
      'type',
    ]);
  }
  final rawChoices = value['choices'];
  if (rawChoices is! List) {
    return _missing('Ein Quiz-Item benötigt choices.', ['choices']);
  }
  final choices = <QuizChoice>[];
  for (final rawChoice in rawChoices) {
    if (rawChoice is! Map<String, dynamic>) {
      return _missing('Eine Quiz-Antwort ist ungültig.', ['choices[]']);
    }
    final choiceId = _string(rawChoice, 'id');
    final label = _string(rawChoice, 'label');
    if (choiceId == null || label == null) {
      return _missing('Eine Quiz-Antwort benötigt id und label.', [
        'choices[].id',
        'choices[].label',
      ]);
    }
    choices.add(QuizChoice(id: choiceId, label: label));
  }
  return Result.success(
    QuizItem(
      id: id,
      levelId: levelId,
      type: type,
      contentVersion: contentVersion,
      prompt: prompt,
      choices: choices,
    ),
  );
}

Result<LevelAttempt> _attempt(Map<String, dynamic> value) {
  final id = _string(value, 'id');
  final levelId = _string(value, 'levelId');
  final contentVersion = _string(value, 'contentVersion');
  final status = switch (value['status']) {
    'active' => LevelAttemptStatus.active,
    'completed' => LevelAttemptStatus.completed,
    'expired' => LevelAttemptStatus.expired,
    _ => null,
  };
  if (id == null ||
      levelId == null ||
      contentVersion == null ||
      status == null) {
    return _missing('Der Lernversuch entspricht nicht dem API-Vertrag.', [
      'id',
      'levelId',
      'contentVersion',
      'status',
    ]);
  }
  return Result.success(
    LevelAttempt(
      id: id,
      levelId: levelId,
      status: status,
      contentVersion: contentVersion,
      startedAt: _date(value['startedAt']),
    ),
  );
}

Result<EventBatchAcknowledgement> _eventAcknowledgement(
  Map<String, dynamic> value,
) {
  final accepted = value['acceptedClientEventIds'];
  if (accepted is! List || accepted.any((id) => id is! String)) {
    return _missing(
      'Die Ereignisbestätigung benötigt acceptedClientEventIds.',
      ['acceptedClientEventIds'],
    );
  }
  final rejectedCodes = <String, String>{};
  final rejected = value['rejected'];
  if (rejected != null && rejected is! List) {
    return _missing('rejected muss eine Liste sein.', ['rejected']);
  }
  if (rejected is List) {
    for (final item in rejected) {
      if (item is Map<String, dynamic>) {
        final code = _string(item, 'code');
        if (code != null) rejectedCodes[code] = _string(item, 'detail') ?? code;
      }
    }
  }
  return Result.success(
    EventBatchAcknowledgement(
      acceptedClientEventIds: accepted.cast<String>(),
      rejectedCodes: rejectedCodes,
    ),
  );
}

Result<LevelCompletion> _completion(Map<String, dynamic> value) {
  final attemptId = _string(value, 'attemptId');
  final passed = value['passed'];
  final score = value['score'];
  final status = switch (value['status']) {
    'completed' => CompletionStatus.completed,
    'failed' => CompletionStatus.failed,
    _ => null,
  };
  if (attemptId == null || passed is! bool || score is! num || status == null) {
    return _missing('Die Abschlussantwort entspricht nicht dem API-Vertrag.', [
      'attemptId',
      'passed',
      'score',
      'status',
    ]);
  }
  final rawProgress = value['progress'];
  final progress = rawProgress is Map<String, dynamic>
      ? _progress(rawProgress)
      : null;
  if (progress case Failure<ProgressSnapshot>(:final failure)) {
    return Result.failure(failure);
  }
  return Result.success(
    LevelCompletion(
      attemptId: attemptId,
      passed: passed,
      score: score.toDouble(),
      status: status,
      progress: progress is Success<ProgressSnapshot> ? progress.value : null,
    ),
  );
}

Result<ProgressSnapshot> _progress(Map<String, dynamic> value) {
  final updatedAt = _date(value['updatedAt']);
  final rawLevels = value['levels'];
  if (updatedAt == null || rawLevels is! List) {
    return _missing('Fortschritt benötigt updatedAt und levels.', [
      'updatedAt',
      'levels',
    ]);
  }
  final levels = <LevelProgressSnapshot>[];
  for (final rawLevel in rawLevels) {
    if (rawLevel is! Map<String, dynamic>) {
      return _missing('Ein Fortschrittseintrag ist ungültig.', ['levels[]']);
    }
    final id = _string(rawLevel, 'levelId');
    final percentage = rawLevel['percentage'];
    final status = switch (rawLevel['status']) {
      'locked' => ProgressStatus.locked,
      'available' => ProgressStatus.available,
      'in_progress' => ProgressStatus.inProgress,
      'completed' => ProgressStatus.completed,
      _ => null,
    };
    if (id == null || percentage is! num || status == null) {
      return _missing(
        'Ein Fortschrittseintrag enthält unvollständige Pflichtfelder.',
        ['levelId', 'percentage', 'status'],
      );
    }
    levels.add(
      LevelProgressSnapshot(
        levelId: id,
        status: status,
        percentage: percentage.toDouble(),
        completedAt: _date(rawLevel['completedAt']),
      ),
    );
  }
  return Result.success(ProgressSnapshot(updatedAt: updatedAt, levels: levels));
}

QuizItemType? _quizType(Object? value) => switch (value) {
  'multiple_choice' => QuizItemType.multipleChoice,
  'flashcard' => QuizItemType.flashcard,
  'image_identification' => QuizItemType.imageIdentification,
  'feature_match' => QuizItemType.featureMatch,
  _ => null,
};

String? _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  return value is String && value.trim().isNotEmpty ? value.trim() : null;
}

DateTime? _date(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toUtc();
}

Result<T> _missing<T>(String message, List<String> fields) =>
    Result.failure(ContractFailure(message: message, missingFields: fields));
