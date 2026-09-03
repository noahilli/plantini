import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
import '../domain/level_collection_progress.dart';
import '../../herbarium/domain/herbarium_models.dart';
import 'widgets/authenticated_page.dart';

/// Screen presenting a single level overview before beginning its quiz.
final class LevelOverviewScreen extends StatefulWidget {
  const LevelOverviewScreen({
    super.key,
    required this.dependencies,
    required this.levelId,
  });

  final AppDependencies dependencies;
  final String levelId;

  @override
  State<LevelOverviewScreen> createState() => _LevelOverviewScreenState();
}

final class _LevelOverviewScreenState extends State<LevelOverviewScreen> {
  late Future<Result<_LevelMission>> _future = _loadMission();

  Future<Result<_LevelMission>> _loadMission() async {
    final contentResult = await widget.dependencies.loadLevel(widget.levelId);
    if (contentResult case Failure<LevelContent>(:final failure)) {
      return Result.failure(failure);
    }
    final content = (contentResult as Success<LevelContent>).value;
    final targetIds = content.level.collectionTargets;
    final results = await Future.wait([
      if (widget.dependencies.listHerbarium != null)
        widget.dependencies.listHerbarium!(pageSize: 100),
      ...targetIds.map(widget.dependencies.loadPlant.call),
    ]);
    final herbariumResult = widget.dependencies.listHerbarium == null
        ? null
        : results.first as Result<List<HerbariumEntry>>;
    if (herbariumResult case Failure<List<HerbariumEntry>>(:final failure)) {
      return Result.failure(failure);
    }
    final confirmedIds = herbariumResult is Success<List<HerbariumEntry>>
        ? herbariumResult.value
              .map((entry) => entry.confirmedPlantId)
              .whereType<String>()
        : const <String>[];
    final plantResults = results.skip(herbariumResult == null ? 0 : 1);
    final plants = <String, Plant>{};
    for (final result in plantResults) {
      if (result case Failure<Plant>(:final failure)) {
        return Result.failure(failure);
      }
      final plant = (result as Success<Plant>).value;
      plants[plant.id] = plant;
    }
    return Result.success(
      _LevelMission(
        content: content,
        targetPlants: plants,
        collection: LevelCollectionProgress.forLevel(
          content.level,
          confirmedIds,
        ),
      ),
    );
  }

  void _reload() => setState(() => _future = _loadMission());

  @override
  Widget build(BuildContext context) => AuthenticatedPage(
    dependencies: widget.dependencies,
    title: 'Lerneinheit',
    body: FutureBuilder<Result<_LevelMission>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        final result = snapshot.data;
        if (result case Failure<_LevelMission>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final mission = result is Success<_LevelMission> ? result.value : null;
        if (mission == null) {
          return const AsyncStateView(kind: AsyncViewKind.empty);
        }
        final content = mission.content;
        final level = content.level;
        final collection = mission.collection;
        final nextPlant = mission.nextMissingPlant;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: 'Lerneinheit bereit',
                      container: true,
                      child: Container(
                        height: 196,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.sage200,
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [AppColors.sage200, AppColors.sage300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              right: 10,
                              bottom: 0,
                              child: Icon(
                                Icons.local_florist,
                                size: 104,
                                color: AppColors.sage500,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'ETAPPE ${level.sequence}',
                                  style: const TextStyle(
                                    color: AppColors.sage800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      level.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      level.learningGoal ??
                          'Lerne die Merkmale dieses Levels kennen.',
                      style: const TextStyle(color: AppColors.neutral700),
                    ),
                    const SizedBox(height: 18),
                    _QuestStages(collection: collection),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEIN FORSCHUNGSAUFTRAG',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.sage700),
                          ),
                          const SizedBox(height: 8),
                          _FactRow(
                            icon: Icons.local_florist_outlined,
                            text: '${level.plantIds.length} Arten kennenlernen',
                          ),
                          const SizedBox(height: 9),
                          _FactRow(
                            icon: Icons.quiz_outlined,
                            text:
                                '${level.requiredQuizIds.length} Quizfragen lösen',
                          ),
                          const SizedBox(height: 9),
                          _FactRow(
                            icon: Icons.workspace_premium_outlined,
                            text:
                                '${(level.minimumScore * 100).round()} % zum Bestehen',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      key: const ValueKey('level-collection-mission'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.sage800,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events_outlined,
                                color: AppColors.accent200,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'SAMMELMISSION · ${collection.collectedCount}/${collection.requiredCount}',
                                  style: const TextStyle(
                                    color: AppColors.neutral100,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              for (
                                var index = 0;
                                index < collection.requiredPlantIds.length;
                                index++
                              )
                                _PlantToken(
                                  number: index + 1,
                                  plant:
                                      mission.targetPlants[collection
                                          .requiredPlantIds[index]],
                                  collected: collection.collectedPlantIds
                                      .contains(
                                        collection.requiredPlantIds[index],
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: collection.fraction,
                              minHeight: 10,
                              color: AppColors.accent300,
                              backgroundColor: AppColors.sage600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            collection.isComplete
                                ? 'Mission erfüllt! Das Abschlussquiz ist freigeschaltet.'
                                : 'Bestätige die Zielpflanzen im Herbarium. Erst dann kannst du dieses Level abschließen.',
                            style: const TextStyle(
                              color: AppColors.neutral100,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          if (!collection.isComplete &&
                              collection.missingPlantIds.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                key: const ValueKey('level-start-expedition'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.accent300,
                                  foregroundColor: AppColors.neutral900,
                                ),
                                onPressed: () => context.go(
                                  '/field?expectedPlantId=${Uri.encodeComponent(nextPlant!.id)}&expectedPlantName=${Uri.encodeComponent(nextPlant.commonName)}',
                                ),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: Text(
                                  nextPlant == null
                                      ? 'Nächste Pflanze sammeln'
                                      : '${nextPlant.commonName} sammeln',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accent100,
                        border: Border.all(color: AppColors.accent300),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates_outlined,
                            color: AppColors.accent800,
                          ),
                          SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Achte auf mehrere Merkmale. Ein einzelnes Foto reicht für eine sichere Bestimmung nicht aus.',
                              style: TextStyle(
                                color: AppColors.accent800,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: FilledButton.icon(
                key: const ValueKey('learning-start-quiz'),
                onPressed: collection.isComplete
                    ? () => context.go(
                        '/quiz/${level.id}?contentVersion=${Uri.encodeComponent(content.contentVersion)}',
                      )
                    : null,
                icon: const Icon(Icons.quiz_outlined),
                label: Text(
                  collection.isComplete
                      ? 'Abschlussquiz starten'
                      : 'Erst Sammelmission abschließen',
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

final class _LevelMission {
  const _LevelMission({
    required this.content,
    required this.collection,
    required this.targetPlants,
  });

  final LevelContent content;
  final LevelCollectionProgress collection;
  final Map<String, Plant> targetPlants;

  Plant? get nextMissingPlant {
    for (final id in collection.missingPlantIds) {
      final plant = targetPlants[id];
      if (plant != null) return plant;
    }
    return null;
  }
}

final class _QuestStages extends StatelessWidget {
  const _QuestStages({required this.collection});

  final LevelCollectionProgress collection;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('level-quest-stages'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neutral100,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.sage200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SO SCHAFFST DU DIESES LEVEL',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.sage700),
        ),
        const SizedBox(height: 14),
        _QuestStage(
          number: 1,
          icon: Icons.menu_book_outlined,
          title: 'Arten entdecken',
          detail: 'Lerne Merkmale und Lebensraum kennen',
          state: _QuestStageState.complete,
        ),
        _QuestConnector(complete: collection.isComplete),
        _QuestStage(
          number: 2,
          icon: Icons.photo_camera_outlined,
          title: 'Zielpflanzen sammeln',
          detail:
              '${collection.collectedCount} von ${collection.requiredCount} im Herbarium bestätigt',
          state: collection.isComplete
              ? _QuestStageState.complete
              : _QuestStageState.active,
        ),
        _QuestConnector(complete: collection.isComplete),
        _QuestStage(
          number: 3,
          icon: Icons.workspace_premium_outlined,
          title: 'Abschlussprüfung',
          detail: collection.isComplete
              ? 'Freigeschaltet – beweise dein Pflanzenwissen'
              : 'Wird erst durch die Sammelmission freigeschaltet',
          state: collection.isComplete
              ? _QuestStageState.active
              : _QuestStageState.locked,
        ),
      ],
    ),
  );
}

enum _QuestStageState { complete, active, locked }

final class _QuestStage extends StatelessWidget {
  const _QuestStage({
    required this.number,
    required this.icon,
    required this.title,
    required this.detail,
    required this.state,
  });

  final int number;
  final IconData icon;
  final String title;
  final String detail;
  final _QuestStageState state;

  @override
  Widget build(BuildContext context) {
    final active = state != _QuestStageState.locked;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state == _QuestStageState.complete
                ? AppColors.sage500
                : state == _QuestStageState.active
                ? AppColors.accent300
                : AppColors.neutral200,
          ),
          child: state == _QuestStageState.complete
              ? const Icon(Icons.check, color: AppColors.neutral100)
              : Icon(
                  state == _QuestStageState.locked ? Icons.lock_outline : icon,
                  color: active ? AppColors.accent800 : AppColors.neutral600,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. $title',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.neutral900 : AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _QuestConnector extends StatelessWidget {
  const _QuestConnector({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: 18,
    margin: const EdgeInsets.only(left: 20, top: 3, bottom: 3),
    color: complete ? AppColors.sage400 : AppColors.neutral300,
  );
}

final class _PlantToken extends StatelessWidget {
  const _PlantToken({
    required this.number,
    required this.plant,
    required this.collected,
  });

  final int number;
  final Plant? plant;
  final bool collected;

  @override
  Widget build(BuildContext context) => Container(
    width: 112,
    constraints: const BoxConstraints(minHeight: 106),
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: collected ? AppColors.sage300 : AppColors.sage700,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: collected ? AppColors.accent200 : AppColors.sage500,
        width: 3,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          collected ? Icons.check : Icons.local_florist_outlined,
          color: collected ? AppColors.sage900 : AppColors.neutral100,
        ),
        const SizedBox(height: 5),
        Text(
          plant?.commonName ?? 'Zielpflanze $number',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: collected ? AppColors.sage900 : AppColors.neutral100,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        if (plant != null) ...[
          const SizedBox(height: 2),
          Text(
            plant!.scientificName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: collected ? AppColors.sage800 : AppColors.sage200,
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    ),
  );
}

final class _FactRow extends StatelessWidget {
  const _FactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.sage200,
        child: Icon(icon, size: 18, color: AppColors.sage800),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    ],
  );
}
