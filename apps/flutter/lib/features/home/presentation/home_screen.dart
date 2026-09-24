import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../../../design_system/world_art.dart';
import '../../catalog/domain/catalog_models.dart';

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
      return ListView(
        key: const ValueKey('ecosystem-list-ready'),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          Row(
            children: [
              Container(
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
              ),
              const SizedBox(width: 9),
              Text(
                'plantini',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sage800,
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                image: AssetImage(WorldArt.forSlug(ecosystems.first.slug)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.sage900.withValues(alpha: .72),
                  BlendMode.srcATop,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  WorldArt.explorer,
                  height: 100,
                  excludeFromSemantics: true,
                ),
                Text(
                  'DEINE SPIELWELT',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AppColors.sage300),
                ),
                const SizedBox(height: 8),
                Text(
                  progress == null
                      ? 'Dein Weg beginnt'
                      : '$completed / ${levels.length} Sterne',
                  style: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(color: AppColors.neutral100),
                ),
                const SizedBox(height: 6),
                Text(
                  active?.title ??
                      (levels.isEmpty
                          ? 'Wähle dein erstes Ökosystem.'
                          : 'Alle Quizlevel geschafft – besuche dein Ökosystem-Finale.'),
                  style: const TextStyle(color: AppColors.sage300),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: AppColors.sage700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (active != null)
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppColors.accent200,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NÄCHSTER SCHRITT',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          active.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.go('/levels/${active!.id}'),
                    child: const Text('Weiter'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          Text('Ökosysteme', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: .88,
            ),
            itemCount: ecosystems.length,
            itemBuilder: (context, index) {
              final ecosystem = ecosystems[index];
              return Material(
                key: ValueKey('ecosystem-card-${ecosystem.id}'),
                color: index == 0 ? AppColors.terracotta : AppColors.bg,
                borderRadius: BorderRadius.circular(23),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/ecosystems/${ecosystem.id}'),
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(WorldArt.forSlug(ecosystem.slug)),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          AppColors.sage900.withValues(alpha: .55),
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.park_outlined, color: AppColors.neutral100),
                        const Spacer(),
                        Text(
                          ecosystem.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral100,
                          ),
                        ),
                      ],
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
