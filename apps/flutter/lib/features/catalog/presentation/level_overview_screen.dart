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
    final herbariumResult = await widget.dependencies.listHerbarium?.call(
      pageSize: 100,
    );
    if (herbariumResult case Failure<List<HerbariumEntry>>(:final failure)) {
      return Result.failure(failure);
    }
    final confirmedIds = herbariumResult is Success<List<HerbariumEntry>>
        ? herbariumResult.value
              .map((entry) => entry.confirmedPlantId)
              .whereType<String>()
        : const <String>[];
    return Result.success(
      _LevelMission(
        content: content,
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
                                  '/field?expectedPlantId=${Uri.encodeComponent(collection.missingPlantIds.first)}&expectedPlantName=${Uri.encodeComponent('Zielpflanze ${collection.collectedCount + 1}')}',
                                ),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Nächste Pflanze sammeln'),
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
  const _LevelMission({required this.content, required this.collection});

  final LevelContent content;
  final LevelCollectionProgress collection;
}

final class _PlantToken extends StatelessWidget {
  const _PlantToken({required this.number, required this.collected});

  final int number;
  final bool collected;

  @override
  Widget build(BuildContext context) => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: collected ? AppColors.sage300 : AppColors.sage700,
      shape: BoxShape.circle,
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
        Text(
          '$number',
          style: TextStyle(
            color: collected ? AppColors.sage900 : AppColors.neutral100,
            fontWeight: FontWeight.w800,
          ),
        ),
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
