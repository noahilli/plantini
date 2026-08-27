import 'package:flutter/material.dart';

import '../../../../core/theme/organic_tokens.dart';
import '../../domain/catalog_models.dart';

class LevelGateCard extends StatelessWidget {
  final Level level;
  final VoidCallback? onTap;

  const LevelGateCard({super.key, required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = level.status == LevelStatus.locked;
    final bool isCompleted = level.status == LevelStatus.completed;

    return Semantics(
      label: 'Level-Karte: ${level.title}',
      button: !isLocked,
      child: Card(
        key: ValueKey('level-card-${level.id}'),
        color: OrganicTokens.creamBackground,
        shape: RoundedRectangleBorder(
          borderRadius: OrganicTokens.borderRadiusLarge,
          side: isCompleted
              ? const BorderSide(color: OrganicTokens.sageSecondary, width: 2)
              : BorderSide.none,
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: OrganicTokens.borderRadiusLarge,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isLocked ? Colors.grey : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (level.learningGoal != null) ...[
                  Text(
                    level.learningGoal!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLocked ? Colors.grey : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: OrganicTokens.borderRadiusSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            level.blockedReason ?? 'Gesperrt',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    '${level.plantIds.length} Arten in diesem Level',
                    style: const TextStyle(
                      color: OrganicTokens.sageSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (level.progress != null)
                    Semantics(
                      label: 'Fortschritt: ${(level.progress! * 100).toInt()}%',
                      child: LinearProgressIndicator(
                        value: level.progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          OrganicTokens.terracottaAction,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                    )
                  else
                    const Text(
                      'Noch nicht begonnen',
                      style: TextStyle(color: Colors.black54),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
