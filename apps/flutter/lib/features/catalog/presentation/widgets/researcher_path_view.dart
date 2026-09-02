import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_models.dart';
import '../../domain/level_collection_progress.dart';
import 'level_gate_card.dart';

final class ResearcherPathView extends StatelessWidget {
  const ResearcherPathView({
    super.key,
    required this.ecosystem,
    required this.levels,
    this.collectionProgress = const {},
    this.onLevelTap,
  });
  final Ecosystem ecosystem;
  final List<Level> levels;
  final Map<String, LevelCollectionProgress> collectionProgress;
  final void Function(Level)? onLevelTap;

  @override
  Widget build(BuildContext context) {
    final sorted = [...levels]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    return Semantics(
      label: 'Forscherpfad für ${ecosystem.title}',
      child: ListView.builder(
        key: const ValueKey('level-list-ready'),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        itemCount: sorted.length + 1,
        itemBuilder: (context, index) {
          if (index == sorted.length) {
            final completed =
                sorted.isNotEmpty &&
                sorted.every((level) => level.status == LevelStatus.completed);
            return _PathFinale(ecosystem: ecosystem, completed: completed);
          }
          final level = sorted[index];
          final unlocked = level.status != LevelStatus.locked;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 45,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: unlocked
                              ? AppColors.sage600
                              : AppColors.neutral200,
                          border: Border.all(
                            color: unlocked
                                ? AppColors.sage300
                                : AppColors.neutral300,
                            width: 3,
                          ),
                        ),
                        child: Text(
                          '${level.sequence}',
                          style: TextStyle(
                            color: unlocked
                                ? AppColors.neutral100
                                : AppColors.neutral700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (index < sorted.length)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: unlocked
                                ? AppColors.sage400
                                : AppColors.neutral400,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Align(
                    alignment: index.isEven
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: .94,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LevelGateCard(
                          level: level,
                          collectionProgress: collectionProgress[level.id],
                          onTap: onLevelTap == null
                              ? null
                              : () => onLevelTap!(level),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class _PathFinale extends StatelessWidget {
  const _PathFinale({required this.ecosystem, required this.completed});

  final Ecosystem ecosystem;
  final bool completed;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 45,
        child: Container(
          key: const ValueKey('level-path-finale'),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? AppColors.accent300 : AppColors.neutral200,
            border: Border.all(
              color: completed ? AppColors.accent700 : AppColors.neutral400,
              width: 3,
            ),
          ),
          child: Icon(
            completed ? Icons.emoji_events : Icons.flag_outlined,
            color: completed ? AppColors.accent800 : AppColors.neutral700,
          ),
        ),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: completed ? AppColors.accent100 : AppColors.bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: completed ? AppColors.accent300 : AppColors.neutral300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                completed ? 'FORSCHUNGSZIEL ERREICHT' : 'DEIN ENDZIEL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: completed ? AppColors.accent800 : AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${ecosystem.title} meistern',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                completed
                    ? 'Du hast alle Zielpflanzen gesammelt und jede Etappe abgeschlossen.'
                    : 'Sammle die Zielpflanzen jeder Etappe und bestehe alle Abschlussquizze.',
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
