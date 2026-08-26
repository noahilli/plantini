import 'package:flutter/material.dart';

import '../../domain/learning_models.dart';

/// View shown upon level attempt completion with score and status.
final class CompletionView extends StatelessWidget {
  const CompletionView({super.key, required this.completion});

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
