import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/learning_models.dart';
import '../domain/learning_repository.dart';

/// Browser/local device persistence for resumable learning state. Tokens are
/// intentionally not stored here; they live in the dedicated credential store.
final class SharedPreferencesLearningSessionStore
    implements LearningSessionStore {
  SharedPreferencesLearningSessionStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<Result<LearningSession?>> read(String levelId) async {
    try {
      final raw = _preferences.getString(_key(levelId));
      if (raw == null) return const Result.success(null);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Session is not an object.');
      }
      return Result.success(_fromJson(decoded));
    } catch (error) {
      debugPrint('SharedPreferencesLearningSessionStore: read failed for level $levelId: $error');
      await _preferences.remove(_key(levelId));
      return Result.failure(
        StorageFailure(
          message: 'Der lokale Lernstand konnte nicht gelesen werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> save(LearningSession session) async {
    try {
      final saved = await _preferences.setString(
        _key(session.levelId),
        jsonEncode(_toJson(session)),
      );
      if (!saved) {
        throw StateError('Shared preferences rejected the learning session.');
      }
      return const Result.success(null);
    } catch (error) {
      debugPrint('SharedPreferencesLearningSessionStore: save failed for level ${session.levelId}: $error');
      return Result.failure(
        StorageFailure(
          message: 'Der Lernstand konnte nicht lokal gespeichert werden.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> delete(String levelId) async {
    try {
      final removed = await _preferences.remove(_key(levelId));
      if (!removed && _preferences.containsKey(_key(levelId))) {
        throw StateError(
          'Shared preferences could not remove the learning session.',
        );
      }
      return const Result.success(null);
    } catch (error) {
      debugPrint('SharedPreferencesLearningSessionStore: delete failed for level $levelId: $error');
      return Result.failure(
        StorageFailure(
          message:
              'Der abgeschlossene Lernstand konnte nicht bereinigt werden.',
          cause: error,
        ),
      );
    }
  }

  String _key(String levelId) => 'plantini.learning.session.v1.$levelId';
}

Map<String, Object?> _toJson(LearningSession session) => {
  'clientAttemptId': session.clientAttemptId,
  'serverAttemptId': session.serverAttemptId,
  'levelId': session.levelId,
  'contentVersion': session.contentVersion,
  'currentQuestionIndex': session.currentQuestionIndex,
  'updatedAt': session.updatedAt.toUtc().toIso8601String(),
  'completionPending': session.completionPending,
  'quizItems': session.quizItems
      .map(
        (item) => {
          'id': item.id,
          'levelId': item.levelId,
          'type': item.type.name,
          'contentVersion': item.contentVersion,
          'prompt': item.prompt,
          'choices': item.choices
              .map((choice) => {'id': choice.id, 'label': choice.label})
              .toList(growable: false),
        },
      )
      .toList(growable: false),
  'answers': session.answers.map((key, value) => MapEntry(key, value.toJson())),
  'pendingEvents': session.pendingEvents
      .map((event) => event.toJson())
      .toList(growable: false),
};

LearningSession _fromJson(Map<String, dynamic> value) {
  String requiredString(String key) {
    final item = value[key];
    if (item is! String || item.isEmpty) {
      throw FormatException('$key is missing.');
    }
    return item;
  }

  final rawItems = value['quizItems'];
  if (rawItems is! List) throw const FormatException('quizItems is missing.');
  final quizItems = rawItems
      .map((raw) {
        if (raw is! Map<String, dynamic>) {
          throw const FormatException('Invalid quiz item.');
        }
        final rawChoices = raw['choices'];
        if (rawChoices is! List) {
          throw const FormatException('Invalid choices.');
        }
        final choices = rawChoices
            .map((choice) {
              if (choice is! Map<String, dynamic> ||
                  choice['id'] is! String ||
                  choice['label'] is! String) {
                throw const FormatException('Invalid choice.');
              }
              return QuizChoice(
                id: choice['id'] as String,
                label: choice['label'] as String,
              );
            })
            .toList(growable: false);
        final type = switch (raw['type']) {
          'multipleChoice' => QuizItemType.multipleChoice,
          'flashcard' => QuizItemType.flashcard,
          'imageIdentification' => QuizItemType.imageIdentification,
          'featureMatch' => QuizItemType.featureMatch,
          _ => null,
        };
        if (type == null ||
            raw['id'] is! String ||
            raw['levelId'] is! String ||
            raw['contentVersion'] is! String ||
            raw['prompt'] is! String) {
          throw const FormatException('Invalid quiz item fields.');
        }
        return QuizItem(
          id: raw['id'] as String,
          levelId: raw['levelId'] as String,
          type: type,
          contentVersion: raw['contentVersion'] as String,
          prompt: raw['prompt'] as String,
          choices: choices,
        );
      })
      .toList(growable: false);
  final rawAnswers = value['answers'];
  if (rawAnswers is! Map<String, dynamic>) {
    throw const FormatException('answers is missing.');
  }
  final answers = <String, QuizAnswer>{};
  for (final entry in rawAnswers.entries) {
    final answer = entry.value;
    if (answer is! Map<String, dynamic> ||
        answer['quizItemId'] is! String ||
        answer['choiceId'] is! String) {
      throw const FormatException('Invalid answer.');
    }
    answers[entry.key] = QuizAnswer(
      quizItemId: answer['quizItemId'] as String,
      choiceId: answer['choiceId'] as String,
    );
  }
  final rawEvents = value['pendingEvents'];
  if (rawEvents is! List) {
    throw const FormatException('pendingEvents is missing.');
  }
  final events = rawEvents
      .map((raw) {
        if (raw is! Map<String, dynamic> ||
            raw['clientEventId'] is! String ||
            raw['type'] is! String ||
            raw['occurredAt'] is! String ||
            raw['payloadVersion'] is! int ||
            raw['payload'] is! Map<String, dynamic>) {
          throw const FormatException('Invalid learning event.');
        }
        final occurredAt = DateTime.tryParse(raw['occurredAt'] as String);
        if (occurredAt == null) {
          throw const FormatException('Invalid event date.');
        }
        return LearningEvent(
          clientEventId: raw['clientEventId'] as String,
          type: raw['type'] as String,
          occurredAt: occurredAt.toUtc(),
          payloadVersion: raw['payloadVersion'] as int,
          payload: Map<String, Object?>.from(raw['payload'] as Map),
        );
      })
      .toList(growable: false);
  final updatedAt = DateTime.tryParse(requiredString('updatedAt'));
  if (updatedAt == null || value['currentQuestionIndex'] is! int) {
    throw const FormatException('Invalid session timestamp.');
  }
  return LearningSession(
    clientAttemptId: requiredString('clientAttemptId'),
    serverAttemptId: value['serverAttemptId'] as String?,
    levelId: requiredString('levelId'),
    contentVersion: requiredString('contentVersion'),
    quizItems: quizItems,
    answers: answers,
    pendingEvents: events,
    currentQuestionIndex: value['currentQuestionIndex'] as int,
    updatedAt: updatedAt.toUtc(),
    completionPending: value['completionPending'] == true,
  );
}
