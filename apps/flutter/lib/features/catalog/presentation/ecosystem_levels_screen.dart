import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
import '../domain/ecosystem_journey.dart';
import 'widgets/ecosystem_finale_card.dart';
import 'widgets/researcher_path_view.dart';

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
      if (widget.dependencies.ecosystemJourneys != null)
        widget.dependencies.ecosystemJourneys!.getProgress(widget.ecosystemId),
    ]);
    final ecosystems = results[0] as Result<List<Ecosystem>>;
    final levelsResult = results[1] as Result<List<Level>>;
    if (ecosystems case Failure<List<Ecosystem>>(:final failure)) {
      return Result.failure(failure);
    }
    if (levelsResult case Failure<List<Level>>(:final failure)) {
      return Result.failure(failure);
    }
    final ecosystem = (ecosystems as Success<List<Ecosystem>>).value
        .where((e) => e.id == widget.ecosystemId)
        .firstOrNull;
    if (ecosystem == null) {
      return const Result.failure(
        ContractFailure(
          message: 'Dieses Ökosystem ist nicht verfügbar.',
          missingFields: ['ecosystem'],
        ),
      );
    }
    final levels = [...(levelsResult as Success<List<Level>>).value]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final progressResult = results.length > 2
        ? results[2] as Result<EcosystemJourney>
        : null;
    final journey = progressResult?.valueOrNull;
    final targets =
        journey?.requiredPlantIds ??
        (levels.isEmpty ? const <String>[] : levels.last.collectionTargets);
    final plants = <String, Plant>{};
    for (final result in await Future.wait(
      targets.map(widget.dependencies.loadPlant.call),
    )) {
      if (result case Success<Plant>(:final value)) plants[value.id] = value;
    }
    return Result.success(
      _EcosystemPath(
        ecosystem: ecosystem,
        levels: levels,
        journey: journey,
        targets: targets,
        plants: plants,
        progressError: progressResult?.failureOrNull?.message,
      ),
    );
  }

  void _reload() => setState(() => _future = _loadPath());
  Future<void> _openLevel(Level level) async {
    if (!level.isUnlocked) return;
    await context.push('/levels/${level.id}');
    if (mounted) _reload();
  }

  @override
  void didUpdateWidget(covariant EcosystemLevelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ecosystemId != widget.ecosystemId) _future = _loadPath();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Lernpfad'),
      leading: IconButton(
        tooltip: 'Ökosysteme',
        onPressed: () => context.go('/ecosystems'),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          tooltip: 'Fortschritt aktualisieren',
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<Result<_EcosystemPath>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        final result = snapshot.data;
        if (result case Failure<_EcosystemPath>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final path = result?.valueOrNull;
        if (path == null || path.levels.isEmpty) {
          return const AsyncStateView(kind: AsyncViewKind.empty);
        }
        final stars =
            path.journey?.completedLevelIds.length ??
            path.levels.where((l) => l.status == LevelStatus.completed).length;
        final collected = path.journey?.collectedPlantIds.length;
        Widget finale() => EcosystemFinaleCard(
          ecosystem: path.ecosystem,
          levels: path.levels,
          targets: path.targets,
          plants: path.plants,
          journey: path.journey,
          progressError: path.progressError,
          onRefresh: _reload,
          onCollect: (plant) async {
            await context.push(
              Uri(
                path: '/field',
                queryParameters: {
                  'expectedPlantId': plant.id,
                  'expectedPlantName': plant.commonName,
                },
              ).toString(),
            );
            if (mounted) _reload();
          },
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path.ecosystem.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$stars / ${path.levels.length} Sterne',
                          style: const TextStyle(
                            color: AppColors.sage700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    key: const ValueKey('ecosystem-collection-goal'),
                    icon: const Icon(Icons.science_outlined),
                    label: Text(
                      collected == null
                          ? 'Sammelziel'
                          : '$collected / ${path.targets.length}',
                    ),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (sheetContext) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: .8,
                        maxChildSize: .95,
                        minChildSize: .4,
                        builder: (_, scroll) => SingleChildScrollView(
                          controller: scroll,
                          padding: const EdgeInsets.all(20),
                          child: EcosystemFinaleCard(
                            ecosystem: path.ecosystem,
                            levels: path.levels,
                            targets: path.targets,
                            plants: path.plants,
                            journey: path.journey,
                            progressError: path.progressError,
                            onRefresh: () {
                              Navigator.pop(sheetContext);
                              _reload();
                            },
                            onCollect: (plant) {
                              Navigator.pop(sheetContext);
                              context.go(
                                Uri(
                                  path: '/field',
                                  queryParameters: {
                                    'expectedPlantId': plant.id,
                                    'expectedPlantName': plant.commonName,
                                  },
                                ).toString(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ResearcherPathView(
                key: ValueKey(path.ecosystem.id),
                ecosystem: path.ecosystem,
                levels: path.levels,
                onLevelTap: _openLevel,
                finale: finale(),
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
    required this.journey,
    required this.targets,
    required this.plants,
    this.progressError,
  });
  final Ecosystem ecosystem;
  final List<Level> levels;
  final EcosystemJourney? journey;
  final List<String> targets;
  final Map<String, Plant> plants;
  final String? progressError;
}
