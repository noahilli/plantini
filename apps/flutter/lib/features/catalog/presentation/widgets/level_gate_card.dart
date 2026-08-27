import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_models.dart';

final class LevelGateCard extends StatelessWidget {
  const LevelGateCard({super.key, required this.level, this.onTap});
  final Level level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = level.status == LevelStatus.locked;
    final active =
        level.status == LevelStatus.available ||
        level.status == LevelStatus.inProgress;
    final completed = level.status == LevelStatus.completed;
    final progress = level.progress?.clamp(0.0, 1.0).toDouble();
    return Semantics(
      label: 'Level-Karte: ${level.title}',
      button: !locked,
      child: Material(
        key: ValueKey('level-card-${level.id}'),
        color: active ? AppColors.neutral100 : AppColors.bg,
        elevation: active ? 2 : 0,
        shadowColor: AppColors.neutral900.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: locked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeColor(level.status),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (locked) ...[
                            const Icon(
                              Icons.lock_outline,
                              size: 13,
                              color: AppColors.neutral800,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            _status(level.status),
                            style: TextStyle(
                              color: locked
                                  ? AppColors.neutral800
                                  : AppColors.neutral100,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!locked)
                      Text(
                        '${level.plantIds.length} Arten in diesem Level',
                        style: const TextStyle(
                          color: AppColors.neutral700,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  locked
                      ? (level.blockedReason ??
                            'Voraussetzung noch nicht erfüllt')
                      : (level.learningGoal ?? 'Veröffentlichte Lernetappe'),
                  style: const TextStyle(
                    color: AppColors.neutral700,
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
                if (!locked) ...[
                  const SizedBox(height: 11),
                  if (level.progress == null && !completed) ...[
                    const Text(
                      'Noch nicht begonnen',
                      style: TextStyle(
                        color: AppColors.neutral700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                  if (level.progress != null || completed)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: completed ? 1 : progress,
                        minHeight: 8,
                        color: AppColors.sage500,
                        backgroundColor: AppColors.neutral200,
                      ),
                    ),
                  if (active) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onTap,
                        child: Text(
                          level.status == LevelStatus.inProgress
                              ? 'Weiterlernen →'
                              : 'Etappe starten →',
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _badgeColor(LevelStatus status) => switch (status) {
  LevelStatus.completed => AppColors.sage600,
  LevelStatus.available || LevelStatus.inProgress => AppColors.sage700,
  LevelStatus.locked => AppColors.neutral300,
};

String _status(LevelStatus status) => switch (status) {
  LevelStatus.completed => 'abgeschlossen',
  LevelStatus.available => 'bereit',
  LevelStatus.inProgress => 'aktiv',
  LevelStatus.locked => 'Gate',
};
