import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_models.dart';
import '../../domain/level_collection_progress.dart';
import 'world_landscape_painter.dart';

/// Traversable world with ten stations per chapter. Earlier levels stay playable.
final class ResearcherPathView extends StatefulWidget {
  const ResearcherPathView({
    super.key,
    required this.ecosystem,
    required this.levels,
    this.collectionProgress = const {},
    this.onLevelTap,
    this.finale,
  });
  final Ecosystem ecosystem;
  final List<Level> levels;
  final Map<String, LevelCollectionProgress> collectionProgress;
  final ValueChanged<Level>? onLevelTap;
  final Widget? finale;
  @override
  State<ResearcherPathView> createState() => _ResearcherPathViewState();
}

final class _ResearcherPathViewState extends State<ResearcherPathView> {
  final _scroll = ScrollController();
  late int _chapter = _activeChapter;
  List<Level> get _sorted =>
      [...widget.levels]..sort((a, b) => a.sequence.compareTo(b.sequence));
  int get _activeChapter {
    final levels = _sorted;
    final index = levels.indexWhere(
      (l) => l.isUnlocked && l.status != LevelStatus.completed,
    );
    return index < 0 ? (math.max(1, levels.length) - 1) ~/ 10 : index ~/ 10;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _showChapter(int chapter) {
    setState(() => _chapter = chapter);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    if (sorted.isEmpty) return const Center(child: Text('Noch keine Level.'));
    final chapters = (sorted.length / 10).ceil();
    final chapter = _chapter.clamp(0, chapters - 1);
    final stations = sorted.skip(chapter * 10).take(10).toList();
    final current = sorted
        .where((l) => l.isUnlocked && l.status != LevelStatus.completed)
        .firstOrNull;
    final completedInChapter = stations
        .where((level) => level.status == LevelStatus.completed)
        .length;
    final rowHeight =
        164.0 *
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 2.0);
    return Column(
      children: [
        _ChapterHeader(
          chapter: chapter,
          chapters: chapters,
          firstLevel: stations.first.sequence,
          lastLevel: stations.last.sequence,
          phaseTitle: _phaseTitle(chapter),
          completed: completedInChapter,
          nextLevel: current?.sequence,
          onPrevious: chapter > 0 ? () => _showChapter(chapter - 1) : null,
          onNext: chapter < chapters - 1
              ? () => _showChapter(chapter + 1)
              : null,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                key: const ValueKey('level-list-ready'),
                controller: _scroll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final centers = [
                          for (var i = 0; i < stations.length; i++)
                            Offset(
                              90 +
                                  (constraints.maxWidth - 180) *
                                      (.5 + .5 * math.sin(i * 1.22)),
                              74 + i * rowHeight,
                            ),
                        ];
                        return Semantics(
                          label: 'Forscherpfad für ${widget.ecosystem.title}',
                          child: SizedBox(
                            height: stations.length * rowHeight + 32,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: WorldLandscapePainter(
                                        centers: centers,
                                        slug: widget.ecosystem.slug,
                                        completed: stations
                                            .map(
                                              (l) =>
                                                  l.status ==
                                                  LevelStatus.completed,
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                for (var i = 0; i < stations.length; i++)
                                  Positioned(
                                    left: centers[i].dx - 86,
                                    top: centers[i].dy - 48,
                                    width: 172,
                                    child: _LevelStation(
                                      level: stations[i],
                                      current: stations[i].id == current?.id,
                                      onTap: widget.onLevelTap == null
                                          ? null
                                          : () =>
                                                widget.onLevelTap!(stations[i]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (chapter == chapters - 1)
                      Padding(
                        key: const ValueKey('level-path-finale'),
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                        child:
                            widget.finale ??
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Dein Endziel: alle Level meistern und die drei Zielpflanzen im Herbarium sammeln.',
                                ),
                              ),
                            ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: FilledButton.icon(
                          onPressed: () => _showChapter(chapter + 1),
                          icon: const Icon(Icons.hiking),
                          label: const Text('Den Weg weiter erkunden'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (current != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('map-resume-level'),
                onPressed: widget.onLevelTap == null
                    ? null
                    : () => widget.onLevelTap!(current),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Level ${current.sequence} spielen'),
              ),
            ),
          ),
      ],
    );
  }

  String _phaseTitle(int chapter) => switch (chapter) {
    0 => 'Entdeckerpfad',
    1 => 'Spurensuche',
    _ => 'Forscherfinale',
  };
}

final class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.chapter,
    required this.chapters,
    required this.firstLevel,
    required this.lastLevel,
    required this.phaseTitle,
    required this.completed,
    required this.nextLevel,
    required this.onPrevious,
    required this.onNext,
  });

  final int chapter;
  final int chapters;
  final int firstLevel;
  final int lastLevel;
  final String phaseTitle;
  final int completed;
  final int? nextLevel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sage100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            key: const ValueKey('map-previous-chapter'),
            tooltip: 'Vorheriger Wegabschnitt',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'ABSCHNITT ${chapter + 1} / $chapters',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.sage800,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  phaseTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Level $firstLevel–$lastLevel · bekannte Pflanzen, neue Fragen'
                  '\n$completed Sterne auf diesem Weg'
                  '${nextLevel == null ? '' : ' · Nächste Station: $nextLevel'}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.neutral700),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            key: const ValueKey('map-next-chapter'),
            tooltip: 'Nächster Wegabschnitt',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    ),
  );
}

final class _LevelStation extends StatelessWidget {
  const _LevelStation({required this.level, required this.current, this.onTap});
  final Level level;
  final bool current;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final complete = level.status == LevelStatus.completed;
    final locked = !level.isUnlocked;
    final color = complete
        ? AppColors.sage600
        : current
        ? AppColors.terracotta
        : AppColors.neutral400;
    final state = complete
        ? 'abgeschlossen, erneut spielen'
        : locked
        ? 'gesperrt'
        : 'spielbar';
    return Semantics(
      label: 'Level ${level.sequence}: ${level.title}, $state',
      button: true,
      enabled: !locked,
      child: Tooltip(
        message: locked
            ? level.blockedReason ??
                  'Bestehe zuerst Level ${level.sequence - 1}.'
            : 'Einleitung, Quiz und Belohnung',
        child: InkWell(
          key: ValueKey('level-card-${level.id}'),
          borderRadius: BorderRadius.circular(28),
          onTap: locked ? null : onTap,
          child: Column(
            children: [
              Icon(
                current
                    ? Icons.hiking_rounded
                    : complete
                    ? Icons.star_rounded
                    : Icons.more_horiz,
                size: 26,
                color: complete ? AppColors.accent700 : AppColors.sage800,
              ),
              Container(
                width: 70,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.neutral100, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .55),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: locked
                    ? const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.neutral100,
                      )
                    : Text(
                        '${level.sequence}',
                        style: const TextStyle(
                          fontSize: 26,
                          color: AppColors.neutral100,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral100.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  level.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: locked ? AppColors.neutral700 : AppColors.sage900,
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
