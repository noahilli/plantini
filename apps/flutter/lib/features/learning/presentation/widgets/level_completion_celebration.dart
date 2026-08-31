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
  });
  final LevelCompletion completion;
  final Level level;
  final Level? nextLevel;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final percent = (completion.score * 100).round();
    return Semantics(
      label: completion.passed
          ? 'Level abgeschlossen: ${level.title}'
          : 'Level nicht abgeschlossen: ${level.title}',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.sage800,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neutral100.withValues(alpha: .14),
                    border: Border.all(color: AppColors.sage400, width: 5),
                  ),
                  child: Text(
                    '$percent%',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: AppColors.neutral100),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUIZ BEENDET',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.sage300),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completion.passed
                            ? 'Level abgeschlossen'
                            : 'Fast geschafft!',
                        key: const ValueKey('learning-level-completed'),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.neutral100),
                      ),
                      if (completion.passed)
                        const Text(
                          'Herzlichen Glückwunsch!',
                          style: TextStyle(
                            color: AppColors.sage300,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (completion.passed && nextLevel != null)
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppColors.accent200,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.terracotta,
                    child: Icon(Icons.auto_awesome, color: AppColors.bg),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GATE OFFEN',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.accent800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          nextLevel!.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.accent900),
                        ),
                        const Text(
                          'Die nächste Etappe wurde serverseitig freigeschaltet.',
                          style: TextStyle(
                            color: AppColors.accent800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                completion.passed
                    ? 'Du hast alle derzeit veröffentlichten Etappen erreicht.'
                    : 'Wiederhole das Quiz. Dein bisheriger Lernfortschritt bleibt erhalten.',
                style: const TextStyle(color: AppColors.neutral700),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            level.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            'Serverseitig bestätigtes Ergebnis: $percent %',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.neutral700),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onContinue,
            child: Text(
              nextLevel != null && completion.passed
                  ? 'Zum nächsten Level'
                  : 'Zurück zur Übersicht',
            ),
          ),
        ],
      ),
    );
  }
}
