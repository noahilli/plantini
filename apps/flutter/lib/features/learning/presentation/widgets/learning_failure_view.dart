import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';

/// Renders a recoverable error state during learning flow.
final class LearningFailureView extends StatelessWidget {
  const LearningFailureView({super.key, required this.failure, this.onRetry});

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
