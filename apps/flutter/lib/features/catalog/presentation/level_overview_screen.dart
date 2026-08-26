import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
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
  late Future<Result<LevelContent>> _future = widget.dependencies.loadLevel(
    widget.levelId,
  );

  void _reload() =>
      setState(() => _future = widget.dependencies.loadLevel(widget.levelId));

  @override
  Widget build(BuildContext context) => AuthenticatedPage(
    dependencies: widget.dependencies,
    title: 'Lerneinheit',
    body: FutureBuilder<Result<LevelContent>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        final result = snapshot.data;
        if (result case Failure<LevelContent>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final content = result is Success<LevelContent> ? result.value : null;
        if (content == null) {
          return const AsyncStateView(kind: AsyncViewKind.empty);
        }
        final level = content.level;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Semantics(
              label: 'Lerneinheit bereit',
              container: true,
              child: Text(
                level.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              level.learningGoal ?? 'Lerne die Merkmale dieses Levels kennen.',
            ),
            const SizedBox(height: 24),
            Text('Bestehensgrenze: ${(level.minimumScore * 100).round()} %'),
            const SizedBox(height: 32),
            FilledButton.icon(
              key: const ValueKey('learning-start-quiz'),
              onPressed: () => context.go(
                '/quiz/${level.id}?contentVersion=${Uri.encodeComponent(content.contentVersion)}',
              ),
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Quiz starten'),
            ),
          ],
        );
      },
    ),
  );
}
