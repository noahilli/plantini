import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../design_system/world_art.dart';
import '../../domain/catalog_models.dart';
import '../../domain/level_collection_progress.dart';
import 'world_landscape_painter.dart';
import 'modular_forest_view.dart';

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
    final world = EcosystemWorld.forSlug(widget.ecosystem.slug);
    if (world != null) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ModularForestView(
            key: ValueKey(widget.ecosystem.id),
            world: world,
            levels: sorted,
            onLevelTap: widget.onLevelTap,
            finale: widget.finale,
          ),
        ),
      );
    }
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
        172.0 *
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
                              118 + i * rowHeight,
                            ),
                        ];
                        return Semantics(
                          label: 'Forscherpfad für ${widget.ecosystem.title}',
                          child: _WorldMap(
                            slug: widget.ecosystem.slug,
                            centers: centers,
                            height: stations.length * rowHeight + 76,
                            completed: stations
                                .map((l) => l.status == LevelStatus.completed)
                                .toList(),
                            stations: stations,
                            current: current,
                            onLevelTap: widget.onLevelTap,
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

final class _WorldMap extends StatelessWidget {
  const _WorldMap({
    required this.slug,
    required this.centers,
    required this.height,
    required this.completed,
    required this.stations,
    required this.current,
    required this.onLevelTap,
  });

  final String slug;
  final List<Offset> centers;
  final double height;
  final List<bool> completed;
  final List<Level> stations;
  final Level? current;
  final ValueChanged<Level>? onLevelTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Positioned.fill(child: _WorldArtwork(slug: slug)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.neutral100.withValues(alpha: .08),
                    AppColors.sage900.withValues(alpha: .13),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: WorldLandscapePainter(
                  centers: centers,
                  slug: slug,
                  completed: completed,
                ),
              ),
            ),
          ),
          for (var i = 0; i < stations.length; i++) ...[
            if (stations[i].id == current?.id)
              Positioned(
                left: centers[i].dx - 30,
                top: centers[i].dy - 104,
                width: 60,
                height: 68,
                child: const _ExplorerMarker(),
              ),
            Positioned(
              left: centers[i].dx - 86,
              top: centers[i].dy - 48,
              width: 172,
              child: _LevelStation(
                level: stations[i],
                current: stations[i].id == current?.id,
                onTap: onLevelTap == null
                    ? null
                    : () => onLevelTap!(stations[i]),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// The artwork is decorative. Its fallback deliberately carries no state.
final class _WorldArtwork extends StatelessWidget {
  const _WorldArtwork({required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context) => Image.asset(
    WorldArt.forSlug(slug),
    fit: BoxFit.cover,
    alignment: Alignment.topCenter,
    filterQuality: FilterQuality.high,
    errorBuilder: (context, error, stackTrace) => const _WorldArtworkFallback(),
  );
}

final class _WorldArtworkFallback extends StatelessWidget {
  const _WorldArtworkFallback();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE5E5C8), Color(0xFFACB88A), Color(0xFF758663)],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          top: 48,
          right: -44,
          child: _AtmosphereOrb(
            color: AppColors.neutral100.withValues(alpha: .24),
            size: 210,
          ),
        ),
        Positioned(
          top: 330,
          left: -90,
          child: _AtmosphereOrb(
            color: AppColors.sage900.withValues(alpha: .16),
            size: 260,
          ),
        ),
      ],
    ),
  );
}

final class _AtmosphereOrb extends StatelessWidget {
  const _AtmosphereOrb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

final class _ExplorerMarker extends StatelessWidget {
  const _ExplorerMarker();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Deine aktuelle Position',
    child: Image.asset(
      WorldArt.explorer,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => const Align(
        alignment: Alignment.bottomCenter,
        child: Icon(Icons.hiking_rounded, color: AppColors.sage900, size: 42),
      ),
    ),
  );
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
    final stone = complete
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
          borderRadius: BorderRadius.circular(32),
          onTap: locked ? null : onTap,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neutral100.withValues(alpha: .82),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  complete
                      ? Icons.star_rounded
                      : locked
                      ? Icons.lock_outline_rounded
                      : current
                      ? Icons.navigation_rounded
                      : Icons.place_outlined,
                  size: 19,
                  color: complete ? AppColors.accent700 : AppColors.sage800,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stone.withValues(alpha: .96),
                        stone.withValues(alpha: .72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.neutral100.withValues(alpha: .8),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sage900.withValues(alpha: .26),
                        blurRadius: 0,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Center(
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
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral100.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neutral100),
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
