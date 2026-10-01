// Walks through the main screens with fake data on a real device/desktop and
// prints frame timings per step (build = UI thread, raster = GPU thread).
//
//   DISPLAY=:0 flutter test integration_test/perf_walk_test.dart -d linux --profile
//
// Numbers are only meaningful in --profile (debug builds are slower by a
// multiple). No network, no login: the app runs on the fakes of the widget flow.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plantini_app/app/plantini_app.dart';
import 'package:plantini_app/features/catalog/presentation/widgets/world_lighting.dart';

import '../test/app_flow_widget_test.dart' show createWidgetFlowDependencies;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final report = <String>[];

  Future<void> step(
    WidgetTester tester,
    String name,
    Future<void> Function() body,
  ) async {
    final timings = <FrameTiming>[];
    void callback(List<FrameTiming> t) => timings.addAll(t);
    binding.addTimingsCallback(callback);
    await body();
    await tester.pump(const Duration(milliseconds: 200));
    binding.removeTimingsCallback(callback);
    if (timings.isEmpty) {
      report.add('$name: no frames');
      return;
    }
    double ms(Duration d) => d.inMicroseconds / 1000;
    final build = timings.map((t) => ms(t.buildDuration)).toList()..sort();
    final raster = timings.map((t) => ms(t.rasterDuration)).toList()..sort();
    final slow = timings.where((t) => ms(t.totalSpan) > 16.7).length;
    final over32 = timings.where((t) => ms(t.totalSpan) > 33).length;
    double p(List<double> v, double q) => v[((v.length - 1) * q).round()];
    report.add(
      '${name.padRight(28)} frames=${timings.length.toString().padLeft(4)} '
      'ui p50=${p(build, .5).toStringAsFixed(1)} p90=${p(build, .9).toStringAsFixed(1)} max=${build.last.toStringAsFixed(1)} | '
      'raster p50=${p(raster, .5).toStringAsFixed(1)} p90=${p(raster, .9).toStringAsFixed(1)} max=${raster.last.toStringAsFixed(1)} | '
      'slow>16.7=$slow >33=$over32',
    );
  }

  testWidgets('walk through the app', (tester) async {
    final deps = createWidgetFlowDependencies(extraLevels: 28);
    await deps.auth.initialize();
    await tester.pumpWidget(PlantiniApp(dependencies: deps));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('auth-login')));
    await tester.pump(const Duration(seconds: 3));

    await step(tester, 'home idle 3s', () async {
      for (var i = 0; i < 180; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    });
    await step(tester, 'home scroll', () async {
      final list = find.byType(Scrollable).first;
      for (var i = 0; i < 3; i++) {
        await tester.fling(list, const Offset(0, -500), 1500);
        await tester.pump(const Duration(seconds: 1));
        await tester.fling(list, const Offset(0, 500), 1500);
        await tester.pump(const Duration(seconds: 1));
      }
    });

    if (const String.fromEnvironment('ONLY_HOME').isNotEmpty) {
      // ignore: avoid_print
      print(
        '\n===== PERF REPORT =====\n${report.join('\n')}\n=======================',
      );
      return;
    }
    await tester.tap(find.text('Lernen').last);
    await tester.pump(const Duration(seconds: 2));
    await step(tester, 'learn list scroll', () async {
      final list = find.byType(Scrollable).first;
      await tester.fling(list, const Offset(0, -400), 1500);
      await tester.pump(const Duration(seconds: 1));
      await tester.fling(list, const Offset(0, 400), 1500);
      await tester.pump(const Duration(seconds: 1));
    });
    final card = find.byKey(const ValueKey('ecosystem-card-eco-wald'));
    if (card.evaluate().isNotEmpty) {
      await tester.tap(card);
      await tester.pump(const Duration(seconds: 2));
      await step(tester, 'path idle 8s (anim)', () async {
        for (var i = 0; i < 480; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      });
      await step(tester, 'path drag', () async {
        final world = find.byType(CustomPaint).first;
        for (var i = 0; i < 4; i++) {
          await tester.drag(world, const Offset(30, -160));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.drag(world, const Offset(-30, 160));
          await tester.pump(const Duration(milliseconds: 300));
        }
      });
      for (final phase in DayPhase.values) {
        DayClock.pin(phase);
        await step(tester, 'path ${phase.name} switch+3s', () async {
          for (var i = 0; i < 180; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        });
      }
      DayClock.pin(null);
      await tester.tap(find.text('Home').last);
      await tester.pump(const Duration(seconds: 1));
    }

    await step(tester, 'herbarium tab', () async {
      await tester.tap(find.text('Herbarium').last);
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    });
    await step(tester, 'herbarium list+scroll', () async {
      await tester.tap(find.text('Beobachtungen').first);
      await tester.pump(const Duration(milliseconds: 500));
      final list = find.byType(Scrollable).first;
      await tester.fling(list, const Offset(0, -400), 1500);
      await tester.pump(const Duration(seconds: 1));
    });
    await step(tester, 'profile tab', () async {
      await tester.tap(find.text('Profil').last);
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    });

    // ignore: avoid_print
    print(
      '\n===== PERF REPORT =====\n${report.join('\n')}\n=======================',
    );
  });
}
