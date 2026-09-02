import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../../herbarium/domain/herbarium_models.dart';
import '../domain/catalog_models.dart';
import '../domain/level_collection_progress.dart';
import 'widgets/authenticated_page.dart';
import 'widgets/researcher_path_view.dart';

/// Screen displaying the levels in an ecosystem learning path.
final class EcosystemLevelsScreen extends StatefulWidget {
  const EcosystemLevelsScreen({
    super.key,
    required this.dependencies,
    required this.ecosystemId,
  });

  final AppDependencies dependencies;
  final String ecosystemId;

  @override
  State<EcosystemLevelsScreen> createState() => _EcosystemLevelsScreenState();
}

final class _EcosystemLevelsScreenState extends State<EcosystemLevelsScreen> {
  late Future<Result<_EcosystemPath>> _future = _loadPath();

  Future<Result<_EcosystemPath>> _loadPath() async {
    final results = await Future.wait([
      widget.dependencies.loadEcosystems(),
      widget.dependencies.loadLevels(widget.ecosystemId),
      if (widget.dependencies.listHerbarium != null)
        widget.dependencies.listHerbarium!(pageSize: 100),
    ]);
    final ecosystems = results[0] as Result<List<Ecosystem>>;
    final levels = results[1] as Result<List<Level>>;
    final herbarium = results.length > 2
        ? results[2] as Result<List<HerbariumEntry>>
        : null;
    if (ecosystems case Failure<List<Ecosystem>>(:final failure)) {
      return Result.failure(failure);
    }
    if (levels case Failure<List<Level>>(:final failure)) {
      return Result.failure(failure);
    }
    if (herbarium case Failure<List<HerbariumEntry>>(:final failure)) {
      return Result.failure(failure);
    }
    Ecosystem? ecosystem;
    for (final candidate in (ecosystems as Success<List<Ecosystem>>).value) {
      if (candidate.id == widget.ecosystemId) {
        ecosystem = candidate;
        break;
      }
    }
    if (ecosystem == null) {
      return const Result.failure(
        ContractFailure(
          message: 'Der Lernpfad verweist auf ein unbekanntes Ökosystem.',
          missingFields: ['ecosystem id'],
        ),
      );
    }
    return Result.success(
      _EcosystemPath(
        ecosystem: ecosystem,
        levels: (levels as Success<List<Level>>).value,
        confirmedPlantIds: herbarium is Success<List<HerbariumEntry>>
            ? herbarium.value
                  .map((entry) => entry.confirmedPlantId)
                  .whereType<String>()
                  .toSet()
            : const {},
      ),
    );
  }

  void _reload() => setState(() => _future = _loadPath());

  @override
  Widget build(BuildContext context) => AuthenticatedPage(
    dependencies: widget.dependencies,
    title: 'Lernpfad',
    body: FutureBuilder<Result<_EcosystemPath>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        final result = snapshot.data;
        if (result case Failure<_EcosystemPath>(:final failure)) {
          if (failure is UnauthorizedFailure) {
            return AsyncStateView(
              kind: AsyncViewKind.permissionDenied,
              title: 'Anmeldung erforderlich',
              message: failure.message,
              onRetry: () async {
                await widget.dependencies.auth.logout();
                await widget.dependencies.auth.login();
              },
            );
          }
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final path = result is Success<_EcosystemPath> ? result.value : null;
        final levels = path?.levels ?? const <Level>[];
        if (levels.isEmpty) {
          return const AsyncStateView(kind: AsyncViewKind.empty);
        }
        if (path == null) {
          return const AsyncStateView(kind: AsyncViewKind.recoverableError);
        }
        return Column(
          children: [
            _NextStepCard(
              ecosystem: path.ecosystem,
              levels: levels,
              collectionProgress: {
                for (final level in levels)
                  level.id: LevelCollectionProgress.forLevel(
                    level,
                    path.confirmedPlantIds,
                  ),
              },
              onOpen: (level) => context.go('/levels/${level.id}'),
            ),
            Expanded(
              child: ResearcherPathView(
                ecosystem: path.ecosystem,
                levels: levels,
                collectionProgress: {
                  for (final level in levels)
                    level.id: LevelCollectionProgress.forLevel(
                      level,
                      path.confirmedPlantIds,
                    ),
                },
                onLevelTap: (level) {
                  if (level.isUnlocked) context.go('/levels/${level.id}');
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}

final class _EcosystemPath {
  const _EcosystemPath({
    required this.ecosystem,
    required this.levels,
    required this.confirmedPlantIds,
  });

  final Ecosystem ecosystem;
  final List<Level> levels;
  final Set<String> confirmedPlantIds;
}

final class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.ecosystem,
    required this.levels,
    required this.collectionProgress,
    required this.onOpen,
  });

  final Ecosystem ecosystem;
  final List<Level> levels;
  final Map<String, LevelCollectionProgress> collectionProgress;
  final ValueChanged<Level> onOpen;

  @override
  Widget build(BuildContext context) {
    final next = levels
        .where(
          (level) => level.isUnlocked && level.status != LevelStatus.completed,
        )
        .firstOrNull;
    final totalProgress = levels.isEmpty
        ? 0.0
        : levels.fold<double>(0, (sum, level) {
                if (level.status == LevelStatus.completed) return sum + 1;
                final collection = collectionProgress[level.id];
                // The field mission is the first half of a level. The
                // server-authoritative quiz completion supplies the rest.
                return sum + ((collection?.fraction ?? 0) * .5);
              }) /
              levels.length;
    final collected = collectionProgress.values.fold<int>(
      0,
      (sum, mission) => sum + mission.collectedCount,
    );
    final required = collectionProgress.values.fold<int>(
      0,
      (sum, mission) => sum + mission.requiredCount,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FORSCHERPFAD',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AppColors.sage700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Dein Weg durch ${ecosystem.title}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 11),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    minHeight: 9,
                    color: AppColors.sage500,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${levels.where((level) => level.status == LevelStatus.completed).length} von ${levels.length} Etappen',
                      style: const TextStyle(
                        color: AppColors.neutral700,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(totalProgress * 100).round()} %',
                      style: const TextStyle(
                        color: AppColors.neutral700,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.collections_bookmark_outlined,
                      size: 16,
                      color: AppColors.sage700,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '$collected von $required Zielpflanzen im Herbarium',
                      style: const TextStyle(
                        color: AppColors.sage800,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Material(
            color: next == null ? AppColors.sage200 : AppColors.accent200,
            borderRadius: BorderRadius.circular(20),
            child: ListTile(
              leading: Icon(
                next == null ? Icons.park_outlined : Icons.explore_outlined,
                color: next == null ? AppColors.sage800 : AppColors.accent800,
              ),
              title: Text(
                next == null
                    ? 'Forscherpfad abgeschlossen'
                    : 'Deine nächste Aufgabe',
              ),
              subtitle: Text(
                next == null
                    ? 'Alle veröffentlichten Etappen geschafft.'
                    : '${next.sequence}. ${next.title}',
              ),
              trailing: next == null ? null : const Icon(Icons.arrow_forward),
              onTap: next == null ? null : () => onOpen(next),
            ),
          ),
        ],
      ),
    );
  }
}
