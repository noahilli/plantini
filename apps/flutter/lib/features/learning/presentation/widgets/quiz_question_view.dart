import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/learning_models.dart';
import 'sync_notice_view.dart';

typedef OnAnswerCallback = void Function(QuizItem item, QuizChoice choice);

/// Renders the active quiz question, progress bar, choice buttons and submit trigger.
final class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.session,
    required this.question,
    required this.busy,
    required this.onAnswer,
    required this.onComplete,
    this.failure,
  });

  final LearningSession session;
  final QuizItem question;
  final bool busy;
  final OnAnswerCallback onAnswer;
  final VoidCallback onComplete;
  final AppFailure? failure;

  @override
  Widget build(BuildContext context) {
    final answered = session.answers.containsKey(question.id);
    final completedAnswers = session.answers.length == session.quizItems.length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (session.answers.isNotEmpty)
          Semantics(
            label: 'Lernstand fortgesetzt',
            child: const Text('Dein lokaler Lernstand wurde wiederhergestellt.'),
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
              onPressed: answered || busy ? null : () => onAnswer(question, choice),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice.label),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (failure != null) ...[
          const SizedBox(height: 12),
          SyncNoticeView(failure: failure!),
        ],
        if (completedAnswers) ...[
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('learning-level-complete'),
            onPressed: busy ? null : onComplete,
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
