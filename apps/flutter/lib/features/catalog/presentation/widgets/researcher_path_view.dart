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
        itemCount: sorted.length,
        itemBuilder: (context, index) {
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
                      if (index < sorted.length - 1)
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
              ],
            ),
          );
        },
      ),
    );
  }
}
