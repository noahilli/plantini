import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/learning_models.dart';

typedef OnAnswerCallback = void Function(QuizItem item, QuizChoice choice);

/// Selection feedback deliberately makes no claim about correctness.
final class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.session,
    required this.question,
    required this.busy,
    required this.onAnswer,
    required this.onComplete,
    this.onNext,
    this.onRetrySync,
    this.failure,
  });

  final LearningSession session;
  final QuizItem question;
  final bool busy;
  final OnAnswerCallback onAnswer;
  final VoidCallback onComplete;
  final VoidCallback? onNext;
  final VoidCallback? onRetrySync;
  final AppFailure? failure;

  @override
  Widget build(BuildContext context) {
    final answer = session.answers[question.id];
    final isLast = session.currentQuestionIndex == session.quizItems.length - 1;
    return ColoredBox(
      color: AppColors.bg,
      child: ListView(
        key: ValueKey('question-page-${question.id}'),
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'Frage ${session.currentQuestionIndex + 1} von ${session.quizItems.length}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: session.answers.length / session.quizItems.length,
            semanticsLabel: 'Beantwortete Fragen',
            semanticsValue:
                '${session.answers.length} von ${session.quizItems.length}',
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.sage700,
            backgroundColor: AppColors.sage200,
          ),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              question.prompt,
              key: const ValueKey('quiz-question'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 20),
          for (final choice in question.choices) ...[
            Semantics(
              selected: answer?.choiceId == choice.id,
              child: OutlinedButton(
                key: ValueKey('quiz-answer-${choice.id}'),
                onPressed: answer != null || busy
                    ? null
                    : () => onAnswer(question, choice),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  disabledForegroundColor: AppColors.ink,
                  backgroundColor: answer?.choiceId == choice.id
                      ? AppColors.sage200
                      : AppColors.neutral100,
                  side: BorderSide(
                    color: answer?.choiceId == choice.id
                        ? AppColors.sage800
                        : AppColors.neutral500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      answer?.choiceId == choice.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(choice.label)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (answer != null) ...[
            Semantics(
              liveRegion: true,
              child: Container(
                key: const ValueKey('quiz-answer-feedback'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.sage200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Antwort gespeichert. Dein Ergebnis erhältst du nach der letzten Frage.',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (failure != null) ...[
            Semantics(liveRegion: true, child: Text(failure!.message)),
            const SizedBox(height: 8),
          ],
          if (session.pendingEvents.isNotEmpty) ...[
            const Text(
              'Antworten sind auf diesem Gerät gespeichert. Synchronisierung ausstehend.',
            ),
            if (onRetrySync != null)
              TextButton(
                onPressed: busy ? null : onRetrySync,
                child: const Text('Jetzt synchronisieren'),
              ),
            const SizedBox(height: 8),
          ],
          if (busy)
            const LinearProgressIndicator(semanticsLabel: 'Wird gespeichert'),
          if (answer != null)
            FilledButton(
              key: ValueKey(isLast ? 'learning-level-complete' : 'quiz-next'),
              onPressed: busy
                  ? null
                  : isLast
                  ? onComplete
                  : onNext,
              child: Text(
                isLast
                    ? session.completionPending
                          ? 'Abschluss erneut synchronisieren'
                          : 'Level abschließen'
                    : 'Weiter',
              ),
            ),
        ],
      ),
    );
  }
}
