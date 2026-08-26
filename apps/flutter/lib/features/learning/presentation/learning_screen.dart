import 'package:flutter/material.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../catalog/presentation/widgets/authenticated_page.dart';
import '../domain/learning_models.dart';
import 'widgets/completion_view.dart';
import 'widgets/learning_failure_view.dart';
import 'widgets/quiz_question_view.dart';

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
  AppFailure? _failure;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await widget.dependencies.learningSessions.beginOrResume(
      levelId: widget.levelId,
      contentVersion: widget.contentVersion,
    );
    if (!mounted) return;
    result.when(
      success: (session) => setState(() {
        _session = session;
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
    );
    if (!mounted) return;
    switch (result) {
      case Success<LearningSession>(:final value):
        setState(() {
          _session = value;
          _busy = false;
          _failure = null;
        });
        final sync = await widget.dependencies.learningSessions
            .submitPendingEvents(value);
        if (!mounted) return;
        switch (sync) {
          case Success<LearningSession>(:final value):
            setState(() => _session = value);
          case Failure<LearningSession>(:final failure):
            setState(() => _failure = failure);
        }
      case Failure<LearningSession>(:final failure):
        setState(() {
          _failure = failure;
          _busy = false;
        });
    }
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
    result.when(
      success: (completion) => setState(() {
        _completion = completion;
        _busy = false;
      }),
      failure: (failure) => setState(() {
        _failure = failure;
        _busy = false;
      }),
    );
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
      return CompletionView(completion: _completion!);
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
      failure: _failure,
    );
  }
}
