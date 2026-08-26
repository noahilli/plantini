enum QuizItemType {
  multipleChoice,
  flashcard,
  imageIdentification,
  featureMatch,
}

final class QuizChoice {
  const QuizChoice({required this.id, required this.label});

  final String id;
  final String label;
}

/// A displayable quiz item. It intentionally contains no answer key: scoring
/// is performed exclusively by `POST /level-attempts/{attemptId}:complete`.
final class QuizItem {
  const QuizItem({
    required this.id,
    required this.levelId,
    required this.type,
    required this.contentVersion,
    required this.prompt,
    required this.choices,
  });

  final String id;
  final String levelId;
  final QuizItemType type;
  final String contentVersion;
  final String prompt;
  final List<QuizChoice> choices;
}

enum LevelAttemptStatus { active, completed, expired }

final class LevelAttempt {
  const LevelAttempt({
    required this.id,
    required this.levelId,
    required this.status,
    required this.contentVersion,
    this.startedAt,
  });

  final String id;
  final String levelId;
  final LevelAttemptStatus status;
  final String contentVersion;
  final DateTime? startedAt;
}

final class QuizAnswer {
  const QuizAnswer({required this.quizItemId, required this.choiceId});

  final String quizItemId;
  final String choiceId;

  Map<String, Object?> toJson() => {
    'quizItemId': quizItemId,
    'choiceId': choiceId,
  };
}

final class LearningEvent {
  const LearningEvent({
    required this.clientEventId,
    required this.type,
    required this.occurredAt,
    required this.payloadVersion,
    required this.payload,
  });

  final String clientEventId;
  final String type;
  final DateTime occurredAt;
  final int payloadVersion;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
    'clientEventId': clientEventId,
    'type': type,
    'occurredAt': occurredAt.toIso8601String(),
    'payloadVersion': payloadVersion,
    'payload': payload,
  };
}

final class EventBatchAcknowledgement {
  const EventBatchAcknowledgement({
    required this.acceptedClientEventIds,
    required this.rejectedCodes,
  });

  final List<String> acceptedClientEventIds;
  final Map<String, String> rejectedCodes;
}

enum CompletionStatus { completed, failed }

final class LevelCompletion {
  const LevelCompletion({
    required this.attemptId,
    required this.passed,
    required this.score,
    required this.status,
    this.progress,
  });

  final String attemptId;
  final bool passed;
  final double score;
  final CompletionStatus status;
  final ProgressSnapshot? progress;
}

enum ProgressStatus { locked, available, inProgress, completed }

final class LevelProgressSnapshot {
  const LevelProgressSnapshot({
    required this.levelId,
    required this.status,
    required this.percentage,
    this.completedAt,
  });

  final String levelId;
  final ProgressStatus status;
  final double percentage;
  final DateTime? completedAt;
}

final class ProgressSnapshot {
  const ProgressSnapshot({required this.updatedAt, required this.levels});

  final DateTime updatedAt;
  final List<LevelProgressSnapshot> levels;
}

/// Persisted locally so a process kill repeats at most the last atomic answer.
final class LearningSession {
  const LearningSession({
    required this.clientAttemptId,
    required this.levelId,
    required this.contentVersion,
    required this.quizItems,
    required this.answers,
    required this.pendingEvents,
    required this.currentQuestionIndex,
    required this.updatedAt,
    this.serverAttemptId,
    this.completionPending = false,
  });

  final String clientAttemptId;
  final String levelId;
  final String contentVersion;
  final List<QuizItem> quizItems;
  final Map<String, QuizAnswer> answers;
  final List<LearningEvent> pendingEvents;
  final int currentQuestionIndex;
  final DateTime updatedAt;
  final String? serverAttemptId;
  final bool completionPending;

  QuizItem? get currentQuestion =>
      currentQuestionIndex >= 0 && currentQuestionIndex < quizItems.length
      ? quizItems[currentQuestionIndex]
      : null;

  LearningSession copyWith({
    String? serverAttemptId,
    Map<String, QuizAnswer>? answers,
    List<LearningEvent>? pendingEvents,
    int? currentQuestionIndex,
    DateTime? updatedAt,
    bool? completionPending,
  }) => LearningSession(
    clientAttemptId: clientAttemptId,
    levelId: levelId,
    contentVersion: contentVersion,
    quizItems: quizItems,
    answers: answers ?? this.answers,
    pendingEvents: pendingEvents ?? this.pendingEvents,
    currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    updatedAt: updatedAt ?? this.updatedAt,
    serverAttemptId: serverAttemptId ?? this.serverAttemptId,
    completionPending: completionPending ?? this.completionPending,
  );
}
