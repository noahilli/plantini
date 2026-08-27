import 'package:flutter/material.dart';

import '../../../../core/theme/organic_tokens.dart';
import '../../domain/learning_models.dart';
import '../../../catalog/domain/catalog_models.dart';

class LevelCompletionCelebration extends StatelessWidget {
  final LevelCompletion completion;
  final Level level;
  final Level? nextLevel;
  final VoidCallback? onContinue;

  const LevelCompletionCelebration({
    super.key,
    required this.completion,
    required this.level,
    this.nextLevel,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Abschluss des Levels ${level.title}',
      child: Container(
        color: OrganicTokens.creamBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                completion.passed
                    ? 'Herzlichen Glückwunsch!'
                    : 'Fast geschafft!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: OrganicTokens.terracottaAction,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (completion.passed)
                Text(
                  'Level abgeschlossen',
                  key: const ValueKey('learning-level-completed'),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              if (completion.passed) const SizedBox(height: 8),
              Text(
                'Du hast das Level "${level.title}" beendet.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: OrganicTokens.borderRadiusLarge,
                  border: Border.all(
                    color: OrganicTokens.sageSecondary,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Dein Ergebnis',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(completion.score * 100).toInt()}%',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: OrganicTokens.sageSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (completion.passed && nextLevel != null) ...[
                Semantics(
                  label: 'Freigeschaltet: ${nextLevel!.title}',
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: OrganicTokens.sageSecondary.withOpacity(0.1),
                      borderRadius: OrganicTokens.borderRadiusSmall,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_open,
                          color: OrganicTokens.sageSecondary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Freigeschaltet',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: OrganicTokens.sageSecondary),
                        ),
                        Text(
                          nextLevel!.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: OrganicTokens.sageSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrganicTokens.terracottaAction,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: OrganicTokens.borderRadiusSmall,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  nextLevel != null && completion.passed
                      ? 'Zum nächsten Level'
                      : 'Zurück zur Übersicht',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
