import 'package:flutter/material.dart';

import '../../domain/catalog_models.dart';
import 'level_gate_card.dart';

class ResearcherPathView extends StatelessWidget {
  final Ecosystem ecosystem;
  final List<Level> levels;
  final void Function(Level)? onLevelTap;

  const ResearcherPathView({
    super.key,
    required this.ecosystem,
    required this.levels,
    this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort levels safely by sequence for the vertical path
    final sortedLevels = List<Level>.from(levels)
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return Semantics(
      label: 'Forscherpfad für ${ecosystem.title}',
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        itemCount: sortedLevels.length,
        separatorBuilder: (context, index) {
          // Vertical line connecting the gates/waypoints
          return Semantics(
            hidden: true,
            child: SizedBox(
              height: 40,
              child: Center(
                child: Container(width: 4, color: Colors.grey.shade300),
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final level = sortedLevels[index];
          return LevelGateCard(
            level: level,
            onTap: onLevelTap != null ? () => onLevelTap!(level) : null,
          );
        },
      ),
    );
  }
}
