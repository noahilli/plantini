import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Opt-in frame diagnostics for performance work on a real device:
/// `--dart-define=PLANTINI_PERF_LOG=true`. Prints one line per second with the
/// frame count and the UI-thread (build/layout/paint) and raster times, so a
/// slow screen can be located without attaching a profiler. Off by default and
/// free when off.
abstract final class FrameStats {
  static const _enabled = bool.fromEnvironment('PLANTINI_PERF_LOG');
  static final _spans = <String, _Span>{};
  static bool _installed = false;

  /// Records the duration of a named piece of work (e.g. a cache miss).
  static void note(String name, Duration duration) {
    if (!_enabled) return;
    (_spans[name] ??= _Span()).add(duration.inMicroseconds / 1000);
  }

  static void install() {
    if (!_enabled || _installed) return;
    _installed = true;
    if (kIsWeb) {
      // The browser reports no frame timings; the named spans still tell how
      // long the work of the views takes.
      Timer.periodic(const Duration(seconds: 1), (_) {
        if (_spans.isEmpty) return;
        // ignore: avoid_print
        print(
          'PERF-SPANS ${_spans.entries.map((e) => '${e.key} n=${e.value.count} avg=${e.value.avg.toStringAsFixed(1)}ms max=${e.value.max.toStringAsFixed(1)}ms').join(' | ')}',
        );
        _spans.clear();
      });
    }
    var frames = 0, slow = 0;
    var build = 0.0, raster = 0.0, maxBuild = 0.0, maxRaster = 0.0;
    var since = DateTime.now();
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final FrameTiming t in timings) {
        final b = t.buildDuration.inMicroseconds / 1000;
        final r = t.rasterDuration.inMicroseconds / 1000;
        frames++;
        build += b;
        raster += r;
        maxBuild = math.max(maxBuild, b);
        maxRaster = math.max(maxRaster, r);
        if (t.totalSpan.inMicroseconds > 20000) slow++;
      }
      final now = DateTime.now();
      if (now.difference(since) < const Duration(seconds: 1)) return;
      final seconds = now.difference(since).inMilliseconds / 1000;
      final notes = _spans.entries
          .map(
            (e) =>
                '${e.key} n=${e.value.count} avg=${e.value.avg.toStringAsFixed(1)}ms max=${e.value.max.toStringAsFixed(1)}ms',
          )
          .join(' | ');
      debugPrint(
        'PERF ${(frames / seconds).toStringAsFixed(1)} fps'
        ' ui avg=${(build / frames).toStringAsFixed(1)}ms max=${maxBuild.toStringAsFixed(1)}ms'
        ' raster avg=${(raster / frames).toStringAsFixed(1)}ms max=${maxRaster.toStringAsFixed(1)}ms'
        ' slow(>20ms)=$slow/$frames${notes.isEmpty ? '' : ' | $notes'}',
      );
      _spans.clear();
      frames = slow = 0;
      build = raster = maxBuild = maxRaster = 0;
      since = now;
    });
  }
}

final class _Span {
  int count = 0;
  double sum = 0, max = 0;
  double get avg => count == 0 ? 0 : sum / count;
  void add(double ms) {
    count++;
    sum += ms;
    max = math.max(max, ms);
  }
}
