// Standalone benchmark for the 3D views. Not imported by main.dart or the router.
// flutter run --release -d linux -t lib/dev/world_bench.dart --dart-define=PLANTINI_PERF_LOG=true
// Cycles through the level path (three worlds), an animated and static vitrines
// and an idle baseline, each for a few seconds, and prints "BENCH phase" markers
// between the one-line-per-second PERF lines of FrameStats.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../core/diagnostics/frame_stats.dart';
import '../core/theme/app_theme.dart';
import '../features/catalog/domain/catalog_models.dart';
import '../features/catalog/presentation/widgets/ecosystem_vitrine.dart';
import '../features/catalog/presentation/widgets/modular_forest_view.dart';

const _phaseSeconds = 9;

/// Home-like screen: hero vitrine, text, three small vitrines, filler; scrolled up
/// and down automatically so scrolling cost with several vitrines shows up.
class _ScrollingHome extends StatefulWidget {
  const _ScrollingHome({this.plain = false});
  final bool plain;
  @override
  State<_ScrollingHome> createState() => _ScrollingHomeState();
}

class _ScrollingHomeState extends State<_ScrollingHome> {
  final controller = ScrollController();
  Timer? timer;
  bool down = true;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!controller.hasClients) return;
      controller.animateTo(
        down ? controller.position.maxScrollExtent : 0,
        duration: const Duration(milliseconds: 1300),
        curve: Curves.easeInOut,
      );
      down = !down;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.plain ? _plain() : _full();

  Widget _plain() => ListView(
    controller: controller,
    padding: const EdgeInsets.all(22),
    children: [
      AspectRatio(
        aspectRatio: 1.18,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      const SizedBox(height: 200),
      SizedBox(
        height: 130,
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.brown.shade200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 240),
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AspectRatio(
            aspectRatio: 1.55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _full() => ListView(
    controller: controller,
    padding: const EdgeInsets.all(22),
    children: [
      const EcosystemVitrine(
        world: EcosystemWorld.alpine,
        title: 'Alpenraum',
        aspectRatio: 1.18,
        animate: true,
      ),
      const SizedBox(height: 200, child: Center(child: Text('Text'))),
      SizedBox(
        height: 130,
        child: Row(
          children: [
            for (final w in EcosystemWorld.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: EcosystemVitrine(
                    world: w,
                    title: w.shortName,
                    aspectRatio: .92,
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 240, child: Center(child: Text('mehr'))),
      for (final w in EcosystemWorld.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EcosystemVitrine(
            world: w,
            title: w.shortName,
            aspectRatio: 1.55,
          ),
        ),
    ],
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FrameStats.install();
  runApp(const _Bench());
}

List<Level> _levels() => [
  for (var i = 0; i < 31; i++)
    Level(
      id: 'l$i',
      ecosystemId: 'e',
      title: 'Level ${i + 1}',
      sequence: i + 1,
      status: i == 0 ? LevelStatus.available : LevelStatus.locked,
      minimumScore: .67,
      requiredQuizIds: const [],
      plantIds: const [],
    ),
];

final class _Bench extends StatefulWidget {
  const _Bench();
  @override
  State<_Bench> createState() => _BenchState();
}

final class _BenchState extends State<_Bench> {
  late final phases = <(String, Widget Function())>[
    (
      'path-forest',
      () => ModularForestView(levels: _levels(), world: EcosystemWorld.forest),
    ),
    (
      'path-meadow',
      () => ModularForestView(levels: _levels(), world: EcosystemWorld.meadow),
    ),
    (
      'path-alpine',
      () => ModularForestView(levels: _levels(), world: EcosystemWorld.alpine),
    ),
    (
      'vitrine-hero-animated',
      () => const Center(
        child: SizedBox(
          width: 360,
          child: EcosystemVitrine(
            world: EcosystemWorld.forest,
            title: 'Wald',
            animate: true,
          ),
        ),
      ),
    ),
    (
      'vitrines-static-x3',
      () => Column(
        children: [
          for (final w in EcosystemWorld.values)
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 240,
                  child: EcosystemVitrine(world: w, title: w.shortName),
                ),
              ),
            ),
        ],
      ),
    ),
    ('scrolling-plain-boxes', () => const _ScrollingHome(plain: true)),
    ('home-like-scrolling', () => const _ScrollingHome()),
    ('idle-baseline', () => const Center(child: Text('idle'))),
  ];
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    debugPrint('BENCH ${phases[0].$1}');
    timer = Timer.periodic(const Duration(seconds: _phaseSeconds), (_) {
      if (index + 1 >= phases.length) {
        debugPrint('BENCH done');
        exit(0);
      }
      setState(() => index++);
      debugPrint('BENCH ${phases[index].$1}');
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 390,
          height: 780,
          child: KeyedSubtree(key: ValueKey(index), child: phases[index].$2()),
        ),
      ),
    ),
  );
}
