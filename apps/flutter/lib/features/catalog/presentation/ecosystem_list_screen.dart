import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/async_state_view.dart';
import '../../../design_system/world_art.dart';
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
            child: ListView(
              key: const ValueKey('ecosystem-list-ready'),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
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
                  child: Chip(label: Text('Alle veröffentlichten Ökosysteme')),
                ),
                const SizedBox(height: 14),
                for (var index = 0; index < ecosystems.length; index++) ...[
                  _EcosystemCard(
                    ecosystem: ecosystems[index],
                    featured: index == 0,
                    onTap: () =>
                        context.go('/ecosystems/${ecosystems[index].id}'),
                  ),
                  const SizedBox(height: 12),
                ],
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Ökosystem ${ecosystem.title}',
    child: Material(
      key: ValueKey('ecosystem-card-${ecosystem.id}'),
      color: AppColors.sage900,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                WorldArt.forSlug(ecosystem.slug),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB1C28B),
                            Color(0xFF61744D),
                            Color(0xFF34422C),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.sage900.withValues(alpha: .68),
                      AppColors.sage900.withValues(alpha: .18),
                      AppColors.sage900.withValues(alpha: .76),
                    ],
                    stops: const [.0, .54, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -62,
              right: -38,
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  color: AppColors.neutral100.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          ecosystem.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.neutral100,
                                fontWeight: FontWeight.w900,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x77000000),
                                    blurRadius: 9,
                                  ),
                                ],
                              ),
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
                              : AppColors.neutral100.withValues(alpha: .9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          featured ? 'Startpunkt' : 'entdecken',
                          style: TextStyle(
                            color: featured ? AppColors.bg : AppColors.sage900,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${ecosystem.levelIds.length} Level · ${ecosystem.description ?? 'Veröffentlichter Lernpfad'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sage900,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expedition öffnen',
                        style: TextStyle(
                          color: AppColors.neutral100,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Forschen →',
                        style: TextStyle(
                          color: AppColors.neutral100,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
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
  );
}
