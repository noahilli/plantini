import 'package:flutter_test/flutter_test.dart';
import 'package:plantini_app/features/catalog/presentation/widgets/world_lighting.dart';
import 'package:plantini_app/features/catalog/presentation/widgets/world_module.dart';

void main() {
  test('the hour picks morning, noon, evening or night', () {
    DayPhase at(int h) => DayPhase.at(DateTime(2026, 9, 30, h));
    expect(at(4), DayPhase.night);
    expect(at(5), DayPhase.morning);
    expect(at(9), DayPhase.morning);
    expect(at(10), DayPhase.noon);
    expect(at(15), DayPhase.noon);
    expect(at(16), DayPhase.evening);
    expect(at(20), DayPhase.evening);
    expect(at(21), DayPhase.night);
    expect(at(0), DayPhase.night);
  });

  test('a pinned phase wins over the clock until it is released', () {
    DayClock.pin(DayPhase.night);
    DayClock.refresh(DateTime(2026, 1, 1, 12));
    expect(DayClock.phase.value, DayPhase.night);
    DayClock.pin(null);
    DayClock.refresh(DateTime(2026, 1, 1, 12));
    expect(DayClock.phase.value, DayPhase.noon);
  });

  test('a face turned to the sun is brighter than one turned away', () {
    for (final phase in DayPhase.values) {
      final light = WorldLighting.of(phase);
      int red(int argb) => (argb >> 16) & 0xFF;
      final lit = light.shade(
        .5,
        .5,
        .5,
        light.toSun[0],
        light.toSun[1],
        light.toSun[2],
        gamma: true,
      );
      final dark = light.shade(
        .5,
        .5,
        .5,
        -light.toSun[0],
        -light.toSun[1],
        -light.toSun[2],
        gamma: true,
      );
      expect(red(lit), greaterThan(red(dark)), reason: phase.name);
    }
  });

  test('night is darker than noon and evening is warmer than noon', () {
    int channel(DayPhase p, int shift) {
      final l = WorldLighting.of(p);
      return (l.shade(
                .6,
                .6,
                .6,
                l.toSun[0],
                l.toSun[1],
                l.toSun[2],
                gamma: true,
              ) >>
              shift) &
          0xFF;
    }

    expect(channel(DayPhase.night, 16), lessThan(channel(DayPhase.noon, 16)));
    final noonWarmth = channel(DayPhase.noon, 16) - channel(DayPhase.noon, 0);
    final eveningWarmth =
        channel(DayPhase.evening, 16) - channel(DayPhase.evening, 0);
    expect(eveningWarmth, greaterThan(noonWarmth));
  });

  test('a mesh throws a shadow away from the sun', () {
    final mesh = WorldMesh({
      'name': 'tree',
      'vertices': [
        [0, 0, 0],
        [1, 0, 0],
        [.5, 0, 2],
      ],
      'faces': [
        [0, 1, 2],
      ],
      'color': [.2, .5, .2],
      'motion': 'tree',
    });
    final evening = WorldLighting.of(DayPhase.evening); // sun on the right
    final shadow = mesh.shadowFor(evening)!;
    // The tip at x = .5, z = 2 lands left of the trunk.
    final xs = [for (final v in shadow.vertices) v[0]];
    expect(xs.reduce((a, b) => a < b ? a : b), lessThan(0));
    expect(shadow.motion, 'shadow');
  });
}
