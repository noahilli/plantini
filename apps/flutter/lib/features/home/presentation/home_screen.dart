import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/widgets/ecosystem_vitrine.dart';
import '../../catalog/presentation/widgets/modular_forest_view.dart'
    show EcosystemWorld;

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends State<HomeScreen> {
  late Future<Result<List<Ecosystem>>> _future = widget.dependencies
      .loadEcosystems();

  void _reload() =>
      setState(() => _future = widget.dependencies.loadEcosystems());

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: FutureBuilder<Result<List<Ecosystem>>>(
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
          return _HomeContent(
            dependencies: widget.dependencies,
            ecosystems: ecosystems,
          );
        },
      ),
    ),
  );
}

final class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.dependencies, required this.ecosystems});

  final AppDependencies dependencies;
  final List<Ecosystem> ecosystems;

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<List<Level>>>(
    future: dependencies.loadLevels(ecosystems.first.id),
    builder: (context, snapshot) {
      final levels = snapshot.data is Success<List<Level>>
          ? (snapshot.data! as Success<List<Level>>).value
          : const <Level>[];
      Level? active;
      for (final level in levels) {
        if (level.isUnlocked && level.status != LevelStatus.completed) {
          active = level;
          break;
        }
      }
      final completed = levels
          .where((level) => level.status == LevelStatus.completed)
          .length;
      final progress = levels.isEmpty ? null : completed / levels.length;
      final theme = Theme.of(context);
      final first = ecosystems.first;
      final world = EcosystemWorld.forSlug(first.slug);
      return ListView(
        key: const ValueKey('ecosystem-list-ready'),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          Row(
            children: [
              const _BrandMark(),
              const SizedBox(width: 9),
              Text('plantini', style: theme.textTheme.headlineSmall),
              const Spacer(),
              if (progress != null)
                _StarChip(completed: completed, total: levels.length),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'DEINE FORSCHUNGSREISE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.sage700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bereit für die nächste Expedition?',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.sage800,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sage900.withValues(alpha: .28),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (world != null)
                  EcosystemVitrine(
                    world: world,
                    title: first.title,
                    aspectRatio: 1.18,
                    animate: true,
                  )
                else
                  const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress == null
                            ? 'Dein Weg beginnt'
                            : '$completed von ${levels.length} Sternen',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        active?.title ??
                            (levels.isEmpty
                                ? 'Wähle dein erstes Ökosystem.'
                                : 'Alle Quizlevel geschafft – besuche dein Ökosystem-Finale.'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.sage200,
                        ),
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            color: AppColors.accent400,
                            backgroundColor: AppColors.sage700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (active != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.accent200,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NÄCHSTER SCHRITT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accent700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(active.title, style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => context.go('/levels/${active!.id}'),
                    child: const Text('Weiter'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 26),
          Text('Ökosysteme', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .92,
            ),
            itemCount: ecosystems.length,
            itemBuilder: (context, index) {
              final ecosystem = ecosystems[index];
              final tileWorld = EcosystemWorld.forSlug(ecosystem.slug);
              return Semantics(
                button: true,
                label: 'Ökosystem ${ecosystem.title}',
                child: Material(
                  key: ValueKey('ecosystem-card-${ecosystem.id}'),
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.go('/ecosystems/${ecosystem.id}'),
                    child: tileWorld != null
                        ? EcosystemVitrine(
                            world: tileWorld,
                            title: tileWorld.shortName,
                            aspectRatio: .92,
                            yaw: .5 + index * .12,
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFB1C28B), Color(0xFF61744D)],
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  ecosystem.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.neutral100,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

final class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 27,
    height: 27,
    decoration: const BoxDecoration(
      color: AppColors.sage700,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(13),
        topRight: Radius.circular(13),
        bottomRight: Radius.circular(13),
        bottomLeft: Radius.circular(4),
      ),
    ),
  );
}

/// Stars earned so far: real progress from the server, nothing invented.
final class _StarChip extends StatelessWidget {
  const _StarChip({required this.completed, required this.total});
  final int completed, total;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$completed von $total Sternen',
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accent200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              size: 18,
              color: AppColors.accent600,
            ),
            const SizedBox(width: 5),
            Text(
              '$completed / $total',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.accent800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
