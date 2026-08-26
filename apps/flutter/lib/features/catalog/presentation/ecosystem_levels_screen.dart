import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
import 'widgets/authenticated_page.dart';

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

String _levelStatusText(Level level) => switch (level.status) {
  LevelStatus.locked => 'Noch gesperrt',
  LevelStatus.available => 'Bereit',
  LevelStatus.inProgress => 'In Bearbeitung',
  LevelStatus.completed => 'Abgeschlossen',
};
