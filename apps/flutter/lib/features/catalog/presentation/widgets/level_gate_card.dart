import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_models.dart';
import '../../domain/level_collection_progress.dart';

final class LevelGateCard extends StatelessWidget {
  const LevelGateCard({
    super.key,
    required this.level,
    this.collectionProgress,
    this.onTap,
  });
  final Level level;
  final LevelCollectionProgress? collectionProgress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = level.status == LevelStatus.locked;
    final active =
        level.status == LevelStatus.available ||
        level.status == LevelStatus.inProgress;
    final completed = level.status == LevelStatus.completed;
    final progress = level.progress?.clamp(0.0, 1.0).toDouble();
    final collection = collectionProgress;
    final collectionComplete = collection?.isComplete ?? false;
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
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.sage200
                            : active
                            ? AppColors.accent100
                            : AppColors.neutral200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        completed
                            ? Icons.workspace_premium
                            : locked
                            ? Icons.lock_outline
                            : Icons.explore_outlined,
                        size: 20,
                        color: completed
                            ? AppColors.sage800
                            : active
                            ? AppColors.accent800
                            : AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(width: 9),
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
                            'LEVEL ${level.sequence} · ${_status(level.status)}',
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
                        collection == null
                            ? '${level.collectionTargets.length} Zielarten'
                            : '${collection.collectedCount}/${collection.requiredCount} gesammelt',
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
                  if (collection != null) ...[
                    Row(
                      children: [
                        for (
                          var index = 0;
                          index < collection.requiredCount;
                          index++
                        ) ...[
                          _SpecimenSlot(
                            collected: collection.collectedPlantIds.contains(
                              collection.requiredPlantIds[index],
                            ),
                          ),
                          if (index < collection.requiredCount - 1)
                            const SizedBox(width: 6),
                        ],
                        const Spacer(),
                        Text(
                          '${collection.collectedCount}/${collection.requiredCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.sage800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          collectionComplete
                              ? Icons.verified
                              : Icons.local_florist_outlined,
                          size: 17,
                          color: collectionComplete
                              ? AppColors.sage700
                              : AppColors.accent800,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            collectionComplete
                                ? 'Herbarium-Schlüssel freigeschaltet'
                                : 'Mission: Sammle noch ${collection.requiredCount - collection.collectedCount} Zielarten',
                            style: const TextStyle(
                              fontSize: 11.5,
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
                        value: collection.fraction,
                        minHeight: 8,
                        color: AppColors.accent500,
                        backgroundColor: AppColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 9),
                  ],
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
                          collectionComplete
                              ? 'Abschlussprüfung starten →'
                              : 'Sammelmission starten →',
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

final class _SpecimenSlot extends StatelessWidget {
  const _SpecimenSlot({required this.collected});

  final bool collected;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: collected ? AppColors.sage300 : AppColors.neutral200,
      border: Border.all(
        color: collected ? AppColors.sage600 : AppColors.neutral400,
        width: 2,
      ),
    ),
    child: Icon(
      collected ? Icons.check : Icons.local_florist_outlined,
      size: 15,
      color: collected ? AppColors.sage900 : AppColors.neutral600,
    ),
  );
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
