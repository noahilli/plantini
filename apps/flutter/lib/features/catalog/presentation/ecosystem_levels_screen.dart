import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
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
    ]);
    final ecosystems = results[0] as Result<List<Ecosystem>>;
    final levels = results[1] as Result<List<Level>>;
    if (ecosystems case Failure<List<Ecosystem>>(:final failure)) {
      return Result.failure(failure);
    }
    if (levels case Failure<List<Level>>(:final failure)) {
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
        return Column(
          children: [
            _NextStepCard(
              levels: levels,
              onOpen: (level) => context.go('/levels/${level.id}'),
            ),
            Expanded(
              child: ResearcherPathView(
                ecosystem: path!.ecosystem,
                levels: levels,
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
  const _EcosystemPath({required this.ecosystem, required this.levels});

  final Ecosystem ecosystem;
  final List<Level> levels;
}

final class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.levels, required this.onOpen});

  final List<Level> levels;
  final ValueChanged<Level> onOpen;

  @override
  Widget build(BuildContext context) {
    final next = levels
        .where(
          (level) => level.isUnlocked && level.status != LevelStatus.completed,
        )
        .firstOrNull;
    if (next == null) {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: const ListTile(
          leading: Icon(Icons.park_outlined),
          title: Text('Forscherpfad abgeschlossen'),
          subtitle: Text(
            'Du hast alle derzeit veröffentlichten Etappen geschafft.',
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.explore_outlined),
        title: const Text('Deine nächste Aufgabe'),
        subtitle: Text('${next.sequence}. ${next.title}'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => onOpen(next),
      ),
    );
  }
}
