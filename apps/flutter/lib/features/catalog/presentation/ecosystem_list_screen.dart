import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../design_system/async_state_view.dart';
import '../domain/catalog_models.dart';
import 'widgets/ecosystem_vitrine.dart';
import 'widgets/modular_forest_view.dart' show EcosystemWorld;

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
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = (constraints.maxWidth - 44).clamp(
                  0.0,
                  1200.0,
                );
                final minimumCardWidth = MediaQuery.textScalerOf(context)
                    .scale(320)
                    .clamp(320.0, 640.0);
                final columns = (contentWidth / minimumCardWidth).floor().clamp(
                  1,
                  3,
                );
                final cardWidth = (contentWidth - (columns - 1) * 16) / columns;
                return ListView(
                  key: const ValueKey('ecosystem-list-ready'),
                  padding: EdgeInsets.fromLTRB(
                    (constraints.maxWidth - contentWidth) / 2,
                    18,
                    (constraints.maxWidth - contentWidth) / 2,
                    28,
                  ),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.sage700,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
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
                    const SizedBox(height: 24),
                    Text(
                      'Ökosysteme',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: AppColors.sage700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Wo willst du forschen?',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text('Alle veröffentlichten Ökosysteme'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (var index = 0; index < ecosystems.length; index++)
                          SizedBox(
                            width: cardWidth,
                            child: _EcosystemCard(
                              ecosystem: ecosystems[index],
                              featured: index == 0,
                              onTap: () => context.go(
                                '/ecosystems/${ecosystems[index].id}',
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.neutral400,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: AppColors.sage500,
                          ),
                          SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Neue Ökosysteme kommen aus dem Content-Release – ohne App-Update.',
                              style: TextStyle(
                                color: AppColors.neutral700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

final class _EcosystemCard extends StatelessWidget {
  const _EcosystemCard({
    required this.ecosystem,
    required this.featured,
    required this.onTap,
  });
  final Ecosystem ecosystem;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = EcosystemWorld.forSlug(ecosystem.slug);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Ökosystem ${ecosystem.title}',
      child: Material(
        key: ValueKey('ecosystem-card-${ecosystem.id}'),
        color: featured ? AppColors.sage800 : AppColors.neutral100,
        elevation: 0,
        shadowColor: AppColors.neutral900,
        borderRadius: BorderRadius.circular(32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (world != null)
                  EcosystemVitrine(
                    world: world,
                    title: world.shortName,
                    aspectRatio: 1.55,
                    yaw: switch (world) {
                      EcosystemWorld.forest => .55,
                      EcosystemWorld.meadow => .42,
                      EcosystemWorld.alpine => .62,
                    },
                  )
                else
                  const AspectRatio(
                    aspectRatio: 1.55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB1C28B), Color(0xFF61744D)],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap, not Row: on narrow phones the wide display face
                      // needs the whole line and the tag drops below it.
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            ecosystem.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: MediaQuery.sizeOf(context).width < 360
                                  ? 21
                                  : null,
                              color: featured
                                  ? AppColors.neutral100
                                  : AppColors.ink,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: featured
                                  ? AppColors.terracotta
                                  : AppColors.sage200,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              featured ? 'Startpunkt' : 'entdecken',
                              style: TextStyle(
                                color: featured
                                    ? AppColors.bg
                                    : AppColors.sage800,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ecosystem.description ?? 'Veröffentlichter Lernpfad',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: featured
                              ? AppColors.sage200
                              : AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaChip(
                            icon: Icons.route_outlined,
                            label: '${ecosystem.levelIds.length} Level',
                            dark: featured,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Forschen  →',
                              style: TextStyle(
                                color: AppColors.bg,
                                fontFamily: 'Caprasimo',
                                fontFamilyFallback:
                                    AppTypography.headingFallback,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.dark = false});
  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: dark ? AppColors.sage300 : AppColors.sage700),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          color: dark ? AppColors.sage200 : AppColors.neutral800,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
