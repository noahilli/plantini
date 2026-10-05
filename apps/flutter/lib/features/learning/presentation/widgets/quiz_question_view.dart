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
    this.onOpenNotebook,
    this.onNext,
    this.onRetrySync,
    this.failure,
    this.selectedChoiceId,
  });

  final LearningSession session;
  final QuizItem question;
  final bool busy;
  final OnAnswerCallback onAnswer;
  final VoidCallback onComplete;
  final VoidCallback? onOpenNotebook;
  final VoidCallback? onNext;
  final VoidCallback? onRetrySync;
  final AppFailure? failure;
  final String? selectedChoiceId;

  @override
  Widget build(BuildContext context) {
    final choiceId = selectedChoiceId ?? session.answers[question.id]?.choiceId;
    final isLast = session.currentQuestionIndex == session.quizItems.length - 1;
    return ColoredBox(
      color: AppColors.bg,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            key: ValueKey('question-page-${question.id}'),
            padding: const EdgeInsets.all(22),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sage800,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: AppColors.neutral100,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WISSENSPFAD',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                letterSpacing: 2,
                                color: AppColors.sage700,
                              ),
                        ),
                        Text(
                          'Frage ${session.currentQuestionIndex + 1} von ${session.quizItems.length}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
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
              if (onOpenNotebook != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const ValueKey('quiz-open-notebook'),
                    onPressed: onOpenNotebook,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Steckbrief nachschlagen'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.sage800, AppColors.sage900],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sage900.withValues(alpha: .14),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    question.prompt,
                    key: const ValueKey('quiz-question'),
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: AppColors.neutral100, height: 1.3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final choice in question.choices) ...[
                Semantics(
                  selected: choiceId == choice.id,
                  child: OutlinedButton(
                    key: ValueKey('quiz-answer-${choice.id}'),
                    onPressed: busy || session.completionPending
                        ? null
                        : () => onAnswer(question, choice),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      disabledForegroundColor: AppColors.ink,
                      backgroundColor: choiceId == choice.id
                          ? AppColors.sage200
                          : AppColors.neutral100,
                      side: BorderSide(
                        color: choiceId == choice.id
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
                        AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: choiceId == choice.id
                                ? AppColors.sage800
                                : AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            String.fromCharCode(
                              65 + question.choices.indexOf(choice),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: choiceId == choice.id
                                  ? AppColors.neutral100
                                  : AppColors.sage800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(choice.label)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (choiceId != null) ...[
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
                      'Du kannst deine Auswahl noch ändern. Erst mit „Weiter“ oder „Level abschließen“ bestätigst du sie. Dein Ergebnis wird am Ende geprüft.',
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
                const LinearProgressIndicator(
                  semanticsLabel: 'Wird gespeichert',
                ),
              if (choiceId != null)
                FilledButton(
                  key: ValueKey(
                    isLast ? 'learning-level-complete' : 'quiz-next',
                  ),
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
        ),
      ),
    );
  }
}
