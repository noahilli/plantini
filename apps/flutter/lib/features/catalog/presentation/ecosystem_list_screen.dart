import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
import 'widgets/authenticated_page.dart';

/// Screen displaying the list of available ecosystems.
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
