import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../catalog/domain/catalog_models.dart';
import '../../domain/learning_models.dart';

final class LevelCompletionCelebration extends StatelessWidget {
  const LevelCompletionCelebration({
    super.key,
    required this.completion,
    required this.level,
    this.nextLevel,
    this.onContinue,
    this.onNextLevel,
    this.onRetry,
    this.busy = false,
  });

  final LevelCompletion completion;
  final Level level;
  final Level? nextLevel;
  final VoidCallback? onContinue;
  final VoidCallback? onNextLevel;
  final VoidCallback? onRetry;
  final bool busy;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      if (completion.passed)
        Semantics(
          label: 'Ein Levelstern verdient',
          child: Container(
            key: ValueKey('learning-earned-star-${level.id}'),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.sage200,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              children: [
                Icon(Icons.star_rounded, size: 80, color: AppColors.accent700),
                Text(
                  'Dein Levelstern',
                  style: TextStyle(color: AppColors.sage800),
                ),
              ],
            ),
          ),
        )
      else
        const Icon(Icons.refresh_rounded, size: 64, color: AppColors.sage800),
      const SizedBox(height: 22),
      Text(
        completion.passed ? 'Herzlichen Glückwunsch!' : 'Fast geschafft!',
        key: const ValueKey('learning-level-completed'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 12),
      Text(
        level.title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      Text(
        '${(completion.score * 100).round()}%',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const Text('Dein bestätigtes Quizergebnis', textAlign: TextAlign.center),
      const SizedBox(height: 18),
      Text(
        completion.passed
            ? 'Dieser Stern gehört zu diesem Level. Wiederholen hilft dir, dein Pflanzenwissen zu festigen.'
            : 'Für dieses Level brauchst du ${(level.minimumScore * 100).round()} %. Lies die Pflanzenlektion noch einmal und starte einen neuen Versuch.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      if (completion.passed && nextLevel != null && nextLevel!.isUnlocked) ...[
        Text(nextLevel!.title, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: busy ? null : onNextLevel,
          child: const Text('Zum nächsten Level'),
        ),
      ],
      if (onRetry != null)
        OutlinedButton(
          key: const ValueKey('learning-retry-quiz'),
          onPressed: busy ? null : onRetry,
          child: Text(
            completion.passed ? 'Level wiederholen' : 'Quiz erneut versuchen',
          ),
        ),
      TextButton(
        onPressed: busy ? null : onContinue,
        child: const Text('Zurück zur Übersicht'),
      ),
      if (busy) const LinearProgressIndicator(),
    ],
  );
}
