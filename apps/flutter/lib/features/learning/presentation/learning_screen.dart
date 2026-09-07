import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../catalog/presentation/widgets/authenticated_page.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/learning_models.dart';
import 'widgets/learning_failure_view.dart';
import 'widgets/level_completion_celebration.dart';
import 'widgets/quiz_question_view.dart';
import 'widgets/plant_lesson_view.dart';

/// Screen coordinating an interactive learning quiz session.
final class LearningScreen extends StatefulWidget {
  const LearningScreen({
    super.key,
    required this.dependencies,
    required this.levelId,
    required this.contentVersion,
  });

  final AppDependencies dependencies;
  final String levelId;
  final String contentVersion;

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

final class _LearningScreenState extends State<LearningScreen> {
  LearningSession? _session;
  LevelCompletion? _completion;
  Level? _level;
  Level? _nextLevel;
  AppFailure? _failure;
  bool _busy = true;
  List<Plant> _plants = const [];
  bool _showIntroduction = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LearningScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId ||
        oldWidget.contentVersion != widget.contentVersion) {
      _session = null;
      _completion = null;
      _level = null;
      _nextLevel = null;
      _plants = const [];
      _showIntroduction = true;
      _load();
    }
  }

  Future<void> _refreshNextLevel() async {
    final level = _level;
    if (level == null) return;
    final result = await widget.dependencies.loadLevels(level.ecosystemId);
    if (!mounted || result is! Success<List<Level>>) return;
    final next = result.value
        .where((item) => item.sequence > level.sequence && item.isUnlocked)
        .fold<Level?>(
          null,
          (current, item) => current == null || item.sequence < current.sequence
              ? item
              : current,
        );
    setState(() => _nextLevel = next);
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    final levelId = widget.levelId;
    final levelResult = await widget.dependencies.loadLevel(levelId);
    if (!mounted || widget.levelId != levelId) return;
    if (levelResult case Failure<LevelContent>(:final failure)) {
      setState(() {
        _failure = failure;
        _busy = false;
      });
      return;
    }
    final content = (levelResult as Success<LevelContent>).value;
    final plants = <Plant>[];
    for (final plantId in content.level.plantIds.toSet()) {
      final result = await widget.dependencies.loadPlant(plantId);
      if (!mounted || widget.levelId != levelId) return;
      if (result case Failure<Plant>(:final failure)) {
        setState(() {
          _failure = failure;
          _busy = false;
        });
        return;
      }
      plants.add((result as Success<Plant>).value);
    }
    if (plants.isEmpty ||
        plants.any((plant) => plant.description.trim().isEmpty)) {
      setState(() {
        _failure = const ContractFailure(
          message: 'Die Pflanzenlektion ist noch nicht vollständig verfügbar.',
          missingFields: ['level.plantIds', 'plant.description'],
        );
        _busy = false;
      });
      return;
    }
    _level = content.level;
    _plants = plants;
    final result = await widget.dependencies.learningSessions.beginOrResume(
      levelId: levelId,
      contentVersion: widget.contentVersion == 'latest'
          ? content.contentVersion
          : widget.contentVersion,
    );
    if (!mounted || widget.levelId != levelId) return;
    result.when(
      success: (session) => setState(() {
        _session = session;
        _showIntroduction = session.answers.isEmpty;
        _busy = false;
      }),
      failure: (failure) => setState(() {
        _failure = failure;
        _busy = false;
      }),
    );
  }

  Future<void> _answer(QuizItem item, QuizChoice choice) async {
    final session = _session;
    if (session == null || _busy || session.answers.containsKey(item.id)) {
      return;
    }
    setState(() => _busy = true);
    final result = await widget.dependencies.learningSessions.recordAnswer(
      session: session,
      quizItemId: item.id,
      choiceId: choice.id,
      holdForFeedback: true,
    );
    if (!mounted) return;
    switch (result) {
      case Success<LearningSession>(:final value):
        setState(() {
          _session = value;
          _failure = null;
        });
        // Keep UI mutations serialized until this snapshot is acknowledged.
        await _sync(value);
      case Failure<LearningSession>(:final failure):
        setState(() {
          _failure = failure;
          _busy = false;
        });
    }
  }

  Future<void> _sync(LearningSession session) async {
    setState(() => _busy = true);
    final result = await widget.dependencies.learningSessions
        .submitPendingEvents(session);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Success<LearningSession>(:final value):
          _session = value;
          _failure = null;
        case Failure<LearningSession>(:final failure):
          _failure = failure;
      }
    });
  }

  Future<void> _next() async {
    if (_busy || _session == null) return;
    setState(() => _busy = true);
    final result = await widget.dependencies.learningSessions.advanceQuestion(
      _session!,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Success<LearningSession>(:final value):
          _session = value;
          _failure = null;
        case Failure<LearningSession>(:final failure):
          _failure = failure;
      }
    });
  }

  Future<void> _retry() async {
    if (_busy || _session == null || _completion == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await widget.dependencies.learningSessions.restartCompleted(
      session: _session!,
      completion: _completion!,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Success<LearningSession>(:final value):
          _session = value;
          _completion = null;
          _nextLevel = null;
          _showIntroduction = true;
        case Failure<LearningSession>(:final failure):
          _failure = failure;
      }
    });
  }

  Future<void> _complete() async {
    final session = _session;
    if (session == null || _busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await widget.dependencies.learningSessions.complete(session);
    if (!mounted) return;
    switch (result) {
      case Success<LevelCompletion>(:final value):
        setState(() {
          _completion = value;
          _busy = false;
        });
        if (value.passed) await _refreshNextLevel();
      case Failure<LevelCompletion>(:final failure):
        setState(() {
          _failure = failure;
          _session = session.copyWith(completionPending: failure.isRetryable);
          _busy = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => AuthenticatedPage(
    dependencies: widget.dependencies,
    title: 'Quiz',
    body: _buildBody(context),
  );

  Widget _buildBody(BuildContext context) {
    if (_busy && _session == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failure != null && _session == null) {
      return LearningFailureView(failure: _failure!, onRetry: _load);
    }
    if (_completion != null) {
      final level = _level;
      if (level == null) return const SizedBox.shrink();
      return Column(
        children: [
          if (_failure != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_failure!.message),
            ),
          Expanded(
            child: LevelCompletionCelebration(
              completion: _completion!,
              level: level,
              nextLevel: _nextLevel,
              busy: _busy,
              onRetry: _retry,
              onNextLevel: _nextLevel == null
                  ? null
                  : () => context.go('/levels/${_nextLevel!.id}'),
              onContinue: () => context.go('/ecosystems/${level.ecosystemId}'),
            ),
          ),
        ],
      );
    }
    final session = _session;
    if (session == null) {
      return const LearningFailureView(
        failure: ConfigurationFailure(
          message: 'Der Lernstand konnte nicht geöffnet werden.',
        ),
      );
    }
    final question = session.currentQuestion;
    if (_showIntroduction && _level != null) {
      return PlantLessonView(
        level: _level!,
        plants: _plants,
        onStart: () => setState(() => _showIntroduction = false),
      );
    }
    if (question == null) {
      return const LearningFailureView(
        failure: ContractFailure(
          message: 'Das Quiz enthält keine gültige aktuelle Frage.',
          missingFields: ['quiz items'],
        ),
      );
    }

    return QuizQuestionView(
      session: session,
      question: question,
      busy: _busy,
      onAnswer: _answer,
      onComplete: _complete,
      onNext: _next,
      onRetrySync: () => _sync(session),
      failure: _failure,
    );
  }
}
