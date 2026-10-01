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
  }) {
    final ndl = (nx * toSun[0] + ny * toSun[1] + nz * toSun[2]).clamp(0.0, 1.0);
    int ch(double base, int c) {
      final v = (base * (ambient[c] + sun[c] * ndl)).clamp(0.0, 1.0);
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
  Color world,
) {
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

/// Soft halos around the lit windows and lanterns ([lights]: x, y, z, radius)
/// in the evening and at night: a pool of light on the ground and a glow
/// around the lamp. [project] maps scene points to the canvas; [dy] shifts a
/// light into the module at that offset along the path.
void paintLightHalos(
  Canvas canvas,
  Size size,
  List<List<double>> lights,
  ui.Offset Function(double x, double y, double z) project,
  double scale,
  WorldLighting lighting, {
  double dy = 0,
}) {
  if (!lighting.lamps || lights.isEmpty) return;
  final strength = lighting.phase == DayPhase.night ? 1.0 : .55;
  const warm = Color(0xFFFFB552);
  for (final light in lights) {
    final radius = light[3] * scale;
    final lamp = project(light[0], light[1] + dy, light[2]);
    if (lamp.dx < -radius * 2 ||
        lamp.dx > size.width + radius * 2 ||
        lamp.dy < -radius * 2 ||
        lamp.dy > size.height + radius * 2) {
      continue;
    }
    final ground = project(light[0], light[1] + dy, 0.1);
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
    canvas.drawCircle(
      lamp,
      radius * .62,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(lamp, radius * .62, [
          warm.withValues(alpha: .75 * strength),
          warm.withValues(alpha: 0),
        ]),
    );
  }
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
