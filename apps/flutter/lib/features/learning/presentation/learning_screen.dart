import 'package:flutter/material.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../catalog/presentation/catalog_screens.dart';
import '../domain/learning_models.dart';

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
    body: _body(context),
  );

  Widget _body(BuildContext context) {
    if (_busy && _session == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failure != null && _session == null) {
      return _LearningFailure(failure: _failure!, onRetry: _load);
    }
    if (_completion != null) return _CompletionView(completion: _completion!);
    final session = _session;
    if (session == null) {
      return const _LearningFailure(
        failure: ConfigurationFailure(
          message: 'Der Lernstand konnte nicht geöffnet werden.',
        ),
      );
    }
    final question = session.currentQuestion;
    if (question == null) {
      return const _LearningFailure(
        failure: ContractFailure(
          message: 'Das Quiz enthält keine gültige aktuelle Frage.',
          missingFields: ['quiz items'],
        ),
      );
    }
    final answered = session.answers.containsKey(question.id);
    final completedAnswers = session.answers.length == session.quizItems.length;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (session.answers.isNotEmpty)
          Semantics(
            label: 'Lernstand fortgesetzt',
            child: Text('Dein lokaler Lernstand wurde wiederhergestellt.'),
          ),
        Semantics(
          label: 'Quizfrage',
          container: true,
          child: Text(
            'Frage ${session.currentQuestionIndex + 1} von ${session.quizItems.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: session.answers.length / session.quizItems.length,
        ),
        const SizedBox(height: 28),
        Text(
          question.prompt,
          key: const ValueKey('quiz-question'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        for (final choice in question.choices) ...[
          Semantics(
            label: 'Antwort ${choice.label}',
            button: true,
            child: OutlinedButton(
              key: ValueKey('quiz-answer-${choice.id}'),
              onPressed: answered || _busy
                  ? null
                  : () => _answer(question, choice),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice.label),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_failure != null) ...[
          const SizedBox(height: 12),
          _SyncNotice(failure: _failure!),
        ],
        if (completedAnswers) ...[
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('learning-level-complete'),
            onPressed: _busy ? null : _complete,
            child: Text(
              session.completionPending
                  ? 'Abschluss erneut synchronisieren'
                  : 'Level abschließen',
            ),
          ),
        ],
      ],
    );
  }
}

final class _LearningFailure extends StatelessWidget {
  const _LearningFailure({required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(failure.message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ],
      ),
    ),
  );
}

final class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Synchronisierung ausstehend',
    liveRegion: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          failure.isRetryable
              ? 'Deine Antwort ist lokal gesichert und wird bei der nächsten Verbindung synchronisiert.'
              : failure.message,
        ),
      ),
    ),
  );
}

final class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.completion});

  final LevelCompletion completion;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Levelabschluss',
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completion.passed
                  ? Icons.workspace_premium_outlined
                  : Icons.restart_alt,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              completion.passed
                  ? 'Level abgeschlossen'
                  : 'Noch einmal versuchen',
              key: const ValueKey('learning-level-completed'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Serverseitiges Ergebnis: ${(completion.score * 100).round()} %',
            ),
          ],
        ),
      ),
    ),
  );
}
