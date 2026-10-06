import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'world_module.dart' show FireflyField;

/// Part of the day an ecosystem is shown in.
enum DayPhase {
  morning('Morgen'),
  noon('Mittag'),
  evening('Abend'),
  night('Nacht');

  const DayPhase(this.label);
  final String label;

  /// 05–10 morning, 10–16 noon, 16–21 evening, 21–05 night (local time).
  static DayPhase at(DateTime time) {
    final h = time.hour;
    if (h >= 5 && h < 10) return morning;
    if (h >= 10 && h < 16) return noon;
    if (h >= 16 && h < 21) return evening;
    return night;
  }
}

/// The phase every ecosystem view uses. It follows the clock; the profile can
/// pin it (to look at another time of day). Nothing here schedules a timer:
/// the app calls [refresh] when it starts and when it returns to the front.
abstract final class DayClock {
  static final ValueNotifier<DayPhase> phase = ValueNotifier(
    DayPhase.at(DateTime.now()),
  );

  /// `null` follows the clock.
  static DayPhase? _pinned;
  static DayPhase? get pinned => _pinned;

  static void pin(DayPhase? value) {
    _pinned = value;
    refresh();
  }

  static void refresh([DateTime? now]) {
    phase.value = _pinned ?? DayPhase.at(now ?? DateTime.now());
  }
}

/// Sun (or moon) and sky for one [DayPhase].
///
/// A face is lit as `base * (ambient + sun * max(0, n·l))` per colour channel,
/// so warm morning and evening light tints the lit sides while the shadow sides
/// keep the cool sky colour. The light direction is in scene space (x right,
/// y into the picture, z up) and points from the surface towards the sun.
final class WorldLighting {
  const WorldLighting._({
    required this.phase,
    required this.toSun,
    required this.sun,
    required this.ambient,
    required this.skyTop,
    required this.skyBottom,
    required this.glow,
    required this.glowAt,
    this.stars = false,
    this.lamps = false,
  });

  final DayPhase phase;
  final List<double> toSun;
  final List<double> sun;
  final List<double> ambient;
  final Color skyTop, skyBottom;

  /// Soft disc of the sun / moon drawn into the backdrop, and where.
  final Color glow;
  final Alignment glowAt;
  final bool stars;

  /// Station lanterns glow.
  final bool lamps;

  static List<double> _unit(double x, double y, double z) {
    final n = math.sqrt(x * x + y * y + z * z);
    return [x / n, y / n, z / n];
  }

  static final _morning = WorldLighting._(
    phase: DayPhase.morning,
    toSun: _unit(-.80, -.30, .45),
    sun: const [.62, .47, .30],
    ambient: const [.56, .60, .72],
    skyTop: const Color(0xFFBFD7EC),
    skyBottom: const Color(0xFFFCE5C9),
    glow: const Color(0xFFFFD79A),
    glowAt: const Alignment(-.85, -.75),
  );
  static final _noon = WorldLighting._(
    phase: DayPhase.noon,
    toSun: _unit(-.18, -.30, .94),
    sun: const [.50, .48, .42],
    ambient: const [.58, .61, .66],
    skyTop: const Color(0xFFCFE6F5),
    skyBottom: const Color(0xFFF1F5E4),
    glow: const Color(0xFFFFF6D0),
    glowAt: Alignment(-.2, -.95),
  );
  static final _evening = WorldLighting._(
    phase: DayPhase.evening,
    toSun: _unit(.82, -.22, .38),
    sun: const [.72, .42, .20],
    ambient: const [.50, .44, .58],
    skyTop: const Color(0xFFE0A58F),
    skyBottom: const Color(0xFFF7D7A6),
    glow: const Color(0xFFFF9B54),
    glowAt: const Alignment(.85, -.70),
    lamps: true,
  );
  static final _night = WorldLighting._(
    phase: DayPhase.night,
    toSun: _unit(.35, -.35, .80),
    sun: const [.16, .21, .36],
    ambient: const [.22, .27, .44],
    skyTop: const Color(0xFF17203F),
    skyBottom: const Color(0xFF34406C),
    glow: const Color(0xFFDCE6FF),
    glowAt: const Alignment(.7, -.78),
    stars: true,
    lamps: true,
  );

  static WorldLighting of(DayPhase phase) => switch (phase) {
    DayPhase.morning => _morning,
    DayPhase.noon => _noon,
    DayPhase.evening => _evening,
    DayPhase.night => _night,
  };

  /// How strongly the farthest scenery melts into the sky (aerial
  /// perspective): the haze is the top colour of the backdrop.
  double get hazeStrength => switch (phase) {
    DayPhase.morning => .26,
    DayPhase.noon => .14,
    DayPhase.evening => .26,
    DayPhase.night => .24,
  };

  /// Backdrop gradient for a world whose own (daylight) tint is [world]: noon
  /// keeps the world's colour, the other phases pull it towards their sky.
  (Color, Color) backdrop(Color world) => switch (phase) {
    DayPhase.noon => (
      Color.lerp(skyTop, world, .55)!,
      Color.lerp(skyBottom, world, .55)!,
    ),
    DayPhase.night => (skyTop, skyBottom),
    _ => (Color.lerp(skyTop, world, .25)!, Color.lerp(skyBottom, world, .35)!),
  };

  /// ARGB of a face with unit normal ([nx], [ny], [nz]) and linear base
  /// colour; [gamma] applies the path view's display step.
  int shade(
    double r,
    double g,
    double b,
    double nx,
    double ny,
    double nz, {
    required bool gamma,
    List<double>? lamp,
  }) {
    final ndl = (nx * toSun[0] + ny * toSun[1] + nz * toSun[2]).clamp(0.0, 1.0);
    int ch(double base, int c) {
      // [lamp]: light of nearby lanterns and windows, added to the sun's.
      final v = (base * (ambient[c] + sun[c] * ndl + (lamp?[c] ?? 0))).clamp(
        0.0,
        1.0,
      );
      return ((gamma ? math.pow(v, 1 / 2.2) : v) * 255).round().clamp(0, 255);
    }

    return 0xFF000000 | (ch(r, 0) << 16) | (ch(g, 1) << 8) | ch(b, 2);
  }
}

/// The sky behind a scene: gradient, the sun or moon as a soft glow, and stars
/// at night. [world] is the world's own daylight tint.
void paintSkyBackdrop(
  Canvas canvas,
  Size size,
  WorldLighting lighting,
  Color world, {
  double loop = 0,
  bool clouds = false,
}) {
  final (top, bottom) = lighting.backdrop(world);
  final rect = Offset.zero & size;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
        top,
        bottom,
      ]),
  );
  final at = Offset(
    size.width * (.5 + lighting.glowAt.x / 2),
    size.height * (.5 + lighting.glowAt.y / 2),
  );
  final radius =
      size.shortestSide * (lighting.phase == DayPhase.night ? .28 : .6);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(at, radius, [
        lighting.glow.withValues(
          alpha: lighting.phase == DayPhase.night ? .55 : .62,
        ),
        lighting.glow.withValues(alpha: 0),
      ]),
  );
  if (lighting.phase == DayPhase.night) {
    canvas.drawCircle(
      at,
      size.shortestSide * .035,
      Paint()..color = const Color(0xFFF4F7FF),
    );
  }
  if (lighting.stars) paintStars(canvas, size, 38);
  if (clouds) paintClouds(canvas, size, lighting, loop);
}

/// Soft cartoon clouds drifting below and beside the little world: the island
/// floats in the sky. [loop] (0..1, one 6 s animation loop) moves them by a
/// few pixels back and forth, so the loop closes.
void paintClouds(
  Canvas canvas,
  Size size,
  WorldLighting lighting,
  double loop,
) {
  final (Color top, Color shade, double alpha) = switch (lighting.phase) {
    DayPhase.morning => (const Color(0xFFFFF1E2), const Color(0xFFE9CFC0), .95),
    DayPhase.noon => (const Color(0xFFFFFFFF), const Color(0xFFD8E6F2), .95),
    DayPhase.evening => (const Color(0xFFFFD9BE), const Color(0xFFE3A38E), .92),
    DayPhase.night => (const Color(0xFF7683B3), const Color(0xFF4A5688), .75),
  };
  final unit = size.shortestSide * .075;
  const spots = [
    (.14, .80, 1.15),
    (.62, .86, 1.5),
    (.92, .76, 1.0),
    (.38, .95, 1.0),
    (.05, .12, .8),
    (.95, .06, .9),
  ];
  for (var i = 0; i < spots.length; i++) {
    final (fx, fy, s) = spots[i];
    final dx = math.sin(loop * math.pi * 2 + i * 1.7) * size.width * .014;
    final c = Offset(size.width * fx + dx, size.height * fy);
    final r = unit * s;
    Path puff(double lift) => Path()
      ..addOval(
        Rect.fromCenter(
          center: c.translate(-r * 1.1, lift),
          width: r * 1.7,
          height: r * 1.2,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: c.translate(-r * .25, lift - r * .35),
          width: r * 1.9,
          height: r * 1.6,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: c.translate(r * .75, lift - r * .1),
          width: r * 1.8,
          height: r * 1.3,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: c.translate(r * 1.55, lift + r * .12),
          width: r * 1.2,
          height: r * .9,
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: c.translate(r * .2, lift + r * .22),
            width: r * 3.6,
            height: r * .8,
          ),
          Radius.circular(r * .4),
        ),
      );
    canvas.drawPath(
      puff(r * .16),
      Paint()..color = shade.withValues(alpha: alpha),
    );
    canvas.drawPath(puff(0), Paint()..color = top.withValues(alpha: alpha));
  }
}

/// Fixed pseudo-random stars in the upper half: the same sky every frame.
void paintStars(Canvas canvas, Size size, int count) {
  final paint = Paint()..color = const Color(0xCCFFFFFF);
  var seed = 7919;
  for (var i = 0; i < count; i++) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    final x = (seed % 1000) / 1000 * size.width;
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    final y = (seed % 1000) / 1000 * size.height * .55;
    canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 1.6 : .9, paint);
  }
}

/// The pool of light a lamp throws on the ground: a flat, soft, warm oval.
/// Painted after the terrain and before everything upright, so trunks and
/// roofs that stand in it cover it.
void paintLightPool(
  Canvas canvas,
  ui.Offset ground,
  double radius,
  WorldLighting lighting,
) {
  final strength = lighting.phase == DayPhase.night ? 1.0 : .55;
  const warm = Color(0xFFFFB552);
  final pool = Rect.fromCenter(
    center: ground,
    width: radius * 2.4,
    height: radius * 1.1,
  );
  canvas.drawOval(
    pool,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        ground,
        radius * 1.2,
        [warm.withValues(alpha: .42 * strength), warm.withValues(alpha: 0)],
        null,
        TileMode.clamp,
        Float64List.fromList([
          1,
          0,
          0,
          0,
          0,
          .46,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
        ]),
      ),
  );
}

/// The glow around a lamp itself. It sits at the lamp's own depth in the
/// scene, so whatever stands nearer to the viewer hides it.
void paintLightOrb(
  Canvas canvas,
  ui.Offset lamp,
  double radius,
  WorldLighting lighting,
) {
  final strength = lighting.phase == DayPhase.night ? 1.0 : .55;
  const warm = Color(0xFFFFB552);
  canvas.drawCircle(
    lamp,
    radius * .56,
    Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(lamp, radius * .56, [
        warm.withValues(alpha: .7 * strength),
        warm.withValues(alpha: 0),
      ]),
  );
}

/// Fireflies as small blinking dots. [phase] is the position in the 6 s loop,
/// [share] (0..1) how many of the swarm are out.
void paintFireflies(
  Canvas canvas,
  FireflyField field,
  ui.Offset Function(double x, double y, double z) project,
  double scale,
  double phase, {
  double dy = 0,
  double share = 1,
  int salt = 0,
}) {
  final glow = Paint()..blendMode = BlendMode.plus;
  final active = (field.count * share).round();
  for (var i = 0; i < active; i++) {
    final f = field.at(i, phase, salt: salt);
    final b = f[3];
    if (b <= .02) continue;
    final at = project(f[0], f[1] + dy, f[2]);
    glow.color = const Color(0xFFD6FF5E).withValues(alpha: .28 * b);
    canvas.drawCircle(at, scale * .12, glow);
    glow.color = const Color(0xFFF4FFB0).withValues(alpha: .95 * b);
    canvas.drawCircle(at, scale * .028 + .6, glow);
  }
}
