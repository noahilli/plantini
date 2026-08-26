import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';

final class EcosystemListScreen extends StatefulWidget {
  const EcosystemListScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<EcosystemListScreen> createState() => _EcosystemListScreenState();
}

final class _EcosystemListScreenState extends State<EcosystemListScreen> {
  late Future<Result<List<Ecosystem>>> _future = widget.dependencies
      .loadEcosystems();

  void _reload() =>
      setState(() => _future = widget.dependencies.loadEcosystems());

  @override
  Widget build(BuildContext context) => AuthenticatedPage(
    dependencies: widget.dependencies,
    title: 'Ökosysteme',
    body: FutureBuilder<Result<List<Ecosystem>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        final result = snapshot.data;
        if (result case Failure<List<Ecosystem>>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final ecosystems = result is Success<List<Ecosystem>>
            ? result.value
            : const <Ecosystem>[];
        if (ecosystems.isEmpty) {
          return const AsyncStateView(kind: AsyncViewKind.empty);
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: Semantics(
            label: 'Ökosystemliste bereit',
            container: true,
            child: ListView.separated(
              key: const ValueKey('ecosystem-list-ready'),
              padding: const EdgeInsets.all(16),
              itemCount: ecosystems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ecosystem = ecosystems[index];
                return Card(
                  child: ListTile(
                    key: ValueKey('ecosystem-card-${ecosystem.id}'),
                    title: Text(ecosystem.title),
                    subtitle: Text(
                      ecosystem.description ?? 'Veröffentlichte Lerninhalte',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/ecosystems/${ecosystem.id}'),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}

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
  late Future<Result<List<Level>>> _future = widget.dependencies.loadLevels(
    widget.ecosystemId,
  );

  void _reload() => setState(
    () => _future = widget.dependencies.loadLevels(widget.ecosystemId),
  );

  @override
  Widget build(BuildContext context) => AuthenticatedPage(
    dependencies: widget.dependencies,
    title: 'Lernpfad',
    body: FutureBuilder<Result<List<Level>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncStateView(kind: AsyncViewKind.loading);
        }
        final result = snapshot.data;
        if (result case Failure<List<Level>>(:final failure)) {
          return AsyncStateView(
            kind: AsyncViewKind.recoverableError,
            failure: failure,
            onRetry: _reload,
          );
        }
        final levels = result is Success<List<Level>>
            ? result.value
            : const <Level>[];
        if (levels.isEmpty) {
          return const AsyncStateView(kind: AsyncViewKind.empty);
        }
        return Semantics(
          label: 'Levelliste bereit',
          container: true,
          child: ListView.separated(
            key: const ValueKey('level-list-ready'),
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final level = levels[index];
              return Card(
                child: ListTile(
                  key: ValueKey('level-card-${level.id}'),
                  title: Text('${level.sequence}. ${level.title}'),
                  subtitle: Text(_levelStatusText(level)),
                  trailing: Icon(
                    level.isUnlocked ? Icons.play_arrow : Icons.lock_outline,
                  ),
                  enabled: level.isUnlocked,
                  onTap: level.isUnlocked
                      ? () => context.go('/levels/${level.id}')
                      : null,
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

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

final class AuthenticatedPage extends StatelessWidget {
  const AuthenticatedPage({
    super.key,
    required this.dependencies,
    required this.title,
    required this.body,
  });

  final AppDependencies dependencies;
  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        IconButton(
          key: const ValueKey('auth-logout'),
          tooltip: 'Abmelden',
          onPressed: dependencies.auth.logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: body,
  );
}

String _levelStatusText(Level level) => switch (level.status) {
  LevelStatus.locked => 'Noch gesperrt',
  LevelStatus.available => 'Bereit',
  LevelStatus.inProgress => 'In Bearbeitung',
  LevelStatus.completed => 'Abgeschlossen',
};
