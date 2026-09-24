import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../../../design_system/world_art.dart';
import '../domain/catalog_models.dart';

/// A station preview; the playable route begins with the plant introduction.
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
  late Future<Result<LevelContent>> _future = widget.dependencies.loadLevel(
    widget.levelId,
  );
  void _reload() =>
      setState(() => _future = widget.dependencies.loadLevel(widget.levelId));
  @override
  void didUpdateWidget(covariant LevelOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      _future = widget.dependencies.loadLevel(widget.levelId);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<LevelContent>>(
    future: _future,
    builder: (context, snapshot) {
      final result = snapshot.data;
      final content = result is Success<LevelContent> ? result.value : null;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lerneinheit'),
          leading: IconButton(
            tooltip: 'Zur Levelkarte',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go(
              content == null
                  ? '/ecosystems'
                  : '/ecosystems/${content.level.ecosystemId}',
            ),
          ),
        ),
        body: snapshot.connectionState != ConnectionState.done
            ? const AsyncStateView(kind: AsyncViewKind.loading)
            : result is Failure<LevelContent>
            ? AsyncStateView(
                kind: AsyncViewKind.recoverableError,
                failure: result.failure,
                onRetry: _reload,
              )
            : content == null
            ? const AsyncStateView(kind: AsyncViewKind.empty)
            : _preview(context, content),
      );
    },
  );

  Widget _preview(BuildContext context, LevelContent content) {
    final level = content.level;
    final complete = level.status == LevelStatus.completed;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            Semantics(
              label: 'Lerneinheit bereit',
              container: true,
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: AppColors.sage800,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    Text(
                      'DEINE REISE · LEVEL ${level.sequence}',
                      style: const TextStyle(
                        color: AppColors.sage300,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: complete
                            ? AppColors.accent300
                            : AppColors.sage600,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppColors.sage400, width: 3),
                      ),
                      child: complete
                          ? const Icon(
                              Icons.star_rounded,
                              size: 58,
                              color: AppColors.accent800,
                            )
                          : Image.asset(
                              WorldArt.explorer,
                              height: 96,
                              excludeFromSemantics: true,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      level.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AppColors.neutral100),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      level.learningGoal ?? 'Entdecke die Pflanze, lerne ihre Merkmale und teste dein Wissen.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.sage200,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              complete ? 'Noch eine Runde?' : 'Dein kleines Abenteuer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const _AdventureStep(
              number: '1',
              title: 'Pflanze entdecken',
              description:
                  'Eine kurze Einleitung zeigt dir Merkmale und Lebensraum.',
              icon: Icons.menu_book_rounded,
            ),
            _AdventureStep(
              number: '2',
              title: '${level.requiredQuizIds.length} Fragen spielen',
              description:
                  'Du brauchst ${(level.minimumScore * 100).round()} % zum Bestehen. Du kannst es erneut versuchen.',
              icon: Icons.quiz_rounded,
            ),
            const _AdventureStep(
              number: '3',
              title: 'Deinen Stern verdienen',
              description: 'Bestehe das Quiz und öffne die nächste Station.',
              icon: Icons.star_rounded,
            ),
            const SizedBox(height: 16),
            if (!level.isUnlocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  level.blockedReason ??
                      'Bestehe zuerst die vorherige Station.',
                ),
              ),
            FilledButton.icon(
              key: const ValueKey('learning-start-quiz'),
              onPressed: !level.isUnlocked
                  ? null
                  : () async {
                      await context.push(
                        '/levels/${level.id}/quiz?contentVersion=${Uri.encodeComponent(content.contentVersion)}',
                      );
                      if (mounted) _reload();
                    },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(complete ? 'Level erneut spielen' : 'Level spielen'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Die drei Zielpflanzen sammelst du jederzeit nebenbei. Sie zählen für das Ökosystem-Finale.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.neutral700, height: 1.5),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context.go('/ecosystems/${level.ecosystemId}'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Vor und zurück auf der Karte'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _AdventureStep extends StatelessWidget {
  const _AdventureStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
  final String number;
  final String title;
  final String description;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.sage200,
            foregroundColor: AppColors.sage800,
            child: Text(number),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.neutral700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: AppColors.sage600),
        ],
      ),
    ),
  );
}
