import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_colors.dart';
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (session.answers.isNotEmpty)
                  Semantics(
                    label: 'Lernstand fortgesetzt',
                    child: const Text(
                      'Dein lokaler Lernstand wurde wiederhergestellt.',
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Frage ${session.currentQuestionIndex + 1} von ${session.quizItems.length}',
                      style: const TextStyle(
                        color: AppColors.neutral700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sage200,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _quizType(question.type),
                        style: const TextStyle(
                          color: AppColors.sage800,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value:
                        (session.currentQuestionIndex + 1) /
                        session.quizItems.length,
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'ARTEN SICHER UNTERSCHEIDEN',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AppColors.sage700),
                ),
                const SizedBox(height: 4),
                Semantics(
                  label: 'Quizfrage',
                  container: true,
                  child: Text(
                    question.prompt,
                    key: const ValueKey('quiz-question'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.sage200,
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [AppColors.sage200, AppColors.sage300],
                    ),
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 74,
                    color: AppColors.sage500,
                  ),
                ),
                const SizedBox(height: 13),
                for (final choice in question.choices) ...[
                  Semantics(
                    label: 'Antwort ${choice.label}',
                    button: true,
                    child: OutlinedButton(
                      key: ValueKey('quiz-answer-${choice.id}'),
                      onPressed: answered || busy
                          ? null
                          : () => onAnswer(question, choice),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.neutral500),
                            ),
                            child: const Icon(Icons.arrow_forward, size: 12),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              choice.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
              ],
            ),
          ),
        ),
        if (completedAnswers)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
            child: FilledButton(
              key: const ValueKey('learning-level-complete'),
              onPressed: busy ? null : onComplete,
              child: Text(
                session.completionPending
                    ? 'Abschluss erneut synchronisieren'
                    : 'Level abschließen',
              ),
            ),
          ),
      ],
    );
  }
}

String _quizType(QuizItemType type) => switch (type) {
  QuizItemType.multipleChoice => 'Merkmale',
  QuizItemType.flashcard => 'Lernkarte',
  QuizItemType.imageIdentification => 'Bilderkennung',
  QuizItemType.featureMatch => 'Zuordnung',
};
