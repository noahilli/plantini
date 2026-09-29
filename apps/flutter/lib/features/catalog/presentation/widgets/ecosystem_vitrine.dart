import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'modular_forest_view.dart' show EcosystemWorld;
import 'world_module.dart';

/// A small display case ("Vitrine") holding a miniature of an ecosystem: the
/// same Blender module as the level path, on a wooden plinth under glass.
///
/// Cost model: the miniature is projected and lit once per (world, angle,
/// size) and then replayed as a cached [ui.Picture]. Static vitrines therefore
/// never repaint. With [animate] the model sways a few degrees for two slow
/// swings (stepping through a handful of cached angles) and then rests; it
/// does not move at all under reduced motion or while the widget is not
/// ticking (off-screen tab).
final class EcosystemVitrine extends StatefulWidget {
  const EcosystemVitrine({
    super.key,
    required this.world,
    this.title,
    this.aspectRatio = 1.25,
    this.yaw = .5,
    this.animate = false,
    this.semanticLabel,
    this.child,
  });

  final EcosystemWorld world;

  /// Engraved on the brass plaque; also the default accessibility label.
  final String? title;
  final double aspectRatio;

  /// Rotation of the miniature in radians.
  final double yaw;
  final bool animate;
  final String? semanticLabel;

  /// Content drawn on top of the glass (chips, buttons).
  final Widget? child;

  @override
  State<EcosystemVitrine> createState() => _EcosystemVitrineState();
}

final class _EcosystemVitrineState extends State<EcosystemVitrine>
    with SingleTickerProviderStateMixin {
  static const _swing = .2; // radians either side of [yaw] while animating
  static const _bucket = .03; // ≈1.7°: angles the picture cache is keyed on

  late Future<WorldModule> _module = WorldModule.load(widget.world.asset);
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );
  late final ValueNotifier<int> _step = ValueNotifier<int>(_stepFor(0));

  int _stepFor(double phase) =>
      ((widget.yaw +
                  (widget.animate
                      ? math.sin(phase * math.pi * 2) * _swing
                      : 0)) /
              _bucket)
          .round();

  @override
  void initState() {
    super.initState();
    _clock.addListener(() {
      final next = _stepFor(_clock.value);
      if (next != _step.value) _step.value = next;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant EcosystemVitrine old) {
    super.didUpdateWidget(old);
    if (old.world != widget.world) {
      _module = WorldModule.load(widget.world.asset);
    }
    _step.value = _stepFor(_clock.value);
    _syncMotion();
  }

  void _syncMotion() {
    final moving =
        widget.animate &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.of(context);
    if (moving && !_clock.isAnimating && _clock.value == 0) {
      // Ambient motion, not a permanent loop: two slow swings, then the model
      // rests. Saves battery and lets widget tests settle.
      _clock.repeat(count: 2);
    } else if (!moving && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    _step.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = widget.world;
    final label =
        widget.semanticLabel ??
        (widget.title == null ? 'Modell' : 'Modell: ${widget.title}');
    return Semantics(
      label: label,
      image: true,
      child: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _CaseBackPainter(world)),
                  FutureBuilder<WorldModule>(
                    future: _module,
                    builder: (context, snapshot) {
                      final module = snapshot.data;
                      if (module == null) return const SizedBox.shrink();
                      return CustomPaint(
                        size: size,
                        painter: _MiniWorldPainter(
                          module,
                          world.asset,
                          _step,
                          _bucket,
                        ),
                      );
                    },
                  ),
                  const CustomPaint(painter: _CaseFrontPainter()),
                  if (widget.title != null)
                    Align(
                      alignment: const Alignment(0, .93),
                      child: _Plaque(widget.title!),
                    ),
                  if (widget.child != null) widget.child!,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Miniature

final class _Face {
  _Face(this.points, this.depth, this.color);
  final List<Offset> points;
  final double depth;
  final Color color;
}

/// Replays cached pictures; recording only happens on a cache miss.
final class _MiniWorldPainter extends CustomPainter {
  _MiniWorldPainter(this.module, this.asset, this.step, this.bucket)
    : super(repaint: step);

  final WorldModule module;
  final String asset;
  final ValueNotifier<int> step;
  final double bucket;

  static final _pictures = <String, ui.Picture>{};
  static const _maxPictures = 40;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final key =
        '$asset|${step.value}|${size.width.round()}x${size.height.round()}';
    var picture = _pictures[key];
    if (picture == null) {
      if (_pictures.length >= _maxPictures) {
        _pictures.remove(_pictures.keys.first)?.dispose();
      }
      picture = _pictures[key] = _record(size, step.value * bucket);
    }
    canvas.drawPicture(picture);
  }

  ui.Picture _record(Size size, double yaw) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fit = _Fit(module, yaw, size);
    final faces = <_Face>[];
    final cosY = math.cos(yaw), sinY = math.sin(yaw);
    for (final mesh in module.meshes) {
      // Level stations belong to the path view, not to a display piece.
      if (mesh.slot != null) continue;
      final ranger = mesh.motion == 'ranger' ? module.slots.first : null;
      final vs = [
        for (final v in mesh.vertices)
          [
            v[0] + (ranger == null ? 0 : ranger[0] + .65),
            v[1] + (ranger == null ? 0 : ranger[1] - .2),
            v[2],
          ],
      ];
      final ps = [for (final v in vs) fit.project(v[0], v[1], v[2])];
      for (final indices in mesh.faces) {
        final a = vs[indices[0]], b = vs[indices[1]], c = vs[indices[2]];
        final ux = b[0] - a[0], uy = b[1] - a[1], uz = b[2] - a[2];
        final vx = c[0] - a[0], vy = c[1] - a[1], vz = c[2] - a[2];
        final nx = uy * vz - uz * vy,
            ny = uz * vx - ux * vz,
            nz = ux * vy - uy * vx;
        final length = math.sqrt(nx * nx + ny * ny + nz * nz);
        // Light stays fixed relative to the viewer while the model turns.
        final lx = nx * cosY - ny * sinY, ly = nx * sinY + ny * cosY;
        // Mesh colours are already display colours: shade them directly. The
        // path view's gamma step would wash the small model out.
        final light =
            .72 +
            .32 *
                (length == 0
                    ? 0
                    : ((-lx * .3 - ly * .4 + nz * .85) / length).clamp(0, 1));
        final base = mesh.color;
        int ch(double c) => (c * light * 255).clamp(0, 255).round();
        final color = Color.fromRGBO(ch(base.r), ch(base.g), ch(base.b), 1);
        double depth(List<double> v) =>
            (v[0] * sinY + v[1] * cosY) * .85 - v[2] * .7;
        faces.add(
          _Face(
            [for (final i in indices) ps[i]],
            (depth(a) + depth(b) + depth(c)) / 3 + _groundDepth(mesh.name),
            color,
          ),
        );
      }
    }
    faces.sort((x, y) => y.depth.compareTo(x.depth));
    final points = <Offset>[], colors = <Color>[];
    for (final face in faces) {
      points.addAll(face.points);
      colors.addAll([face.color, face.color, face.color]);
    }
    if (points.isNotEmpty) {
      final vertices = ui.Vertices(
        ui.VertexMode.triangles,
        points,
        colors: colors,
      );
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
      vertices.dispose();
    }
    return recorder.endRecording();
  }

  // Broad terrain planes first, then props (same rule as the level path).
  double _groundDepth(String name) {
    if (name == 'earth' || name == 'grass') return 1000000;
    if (name.startsWith('Sandy stream')) return 900000;
    if (name.startsWith('Flowing woodland')) return 800000;
    if (name.startsWith('Animated water')) return 700000;
    return 0;
  }

  @override
  bool shouldRepaint(covariant _MiniWorldPainter old) =>
      old.module != module || old.asset != asset;
}

/// Fit-to-bounds projection: the module's bounding box is projected at the
/// given angle and scaled into the free area between glass edge and plinth.
final class _Fit {
  _Fit(WorldModule module, this.yaw, Size size) {
    var minX = 1e9, maxX = -1e9, minY = 1e9, maxY = -1e9;
    var minZ = 1e9, maxZ = -1e9;
    for (final mesh in module.meshes) {
      if (mesh.slot != null) continue;
      for (final v in mesh.vertices) {
        minX = math.min(minX, v[0]);
        maxX = math.max(maxX, v[0]);
        minY = math.min(minY, v[1]);
        maxY = math.max(maxY, v[1]);
        minZ = math.min(minZ, v[2]);
        maxZ = math.max(maxZ, v[2]);
      }
    }
    var sx0 = 1e9, sx1 = -1e9, sy0 = 1e9, sy1 = -1e9;
    for (final x in [minX, maxX]) {
      for (final y in [minY, maxY]) {
        for (final z in [minZ, maxZ]) {
          final p = _raw(x, y, z);
          sx0 = math.min(sx0, p.dx);
          sx1 = math.max(sx1, p.dx);
          sy0 = math.min(sy0, p.dy);
          sy1 = math.max(sy1, p.dy);
        }
      }
    }
    // Free area inside the glass: margins left/right/top, plinth below.
    final area = Rect.fromLTWH(
      size.width * .05,
      size.height * .07,
      size.width * .90,
      size.height * .69,
    );
    scale = math.min(area.width / (sx1 - sx0), area.height / (sy1 - sy0));
    origin = Offset(
      area.center.dx - (sx0 + sx1) / 2 * scale,
      area.bottom - sy1 * scale,
    );
  }

  final double yaw;
  late final double scale;
  late final Offset origin;

  Offset _raw(double x, double y, double z) => Offset(
    x * math.cos(yaw) - y * math.sin(yaw),
    -(x * math.sin(yaw) + y * math.cos(yaw)) * .7 - z * .85,
  );

  Offset project(double x, double y, double z) {
    final p = _raw(x, y, z);
    return Offset(origin.dx + p.dx * scale, origin.dy + p.dy * scale);
  }
}

// ---------------------------------------------------------------------------
// Case: back wall + plinth behind the model, glass + brass in front of it.

final class _CaseBackPainter extends CustomPainter {
  const _CaseBackPainter(this.world);
  final EcosystemWorld world;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(28.0, size.shortestSide * .12);
    final clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(r),
    );
    canvas.save();
    canvas.clipRRect(clip);

    // Back wall: a soft, slightly tinted gallery light.
    final tint = world.background;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
          Color.lerp(const Color(0xFFFFFCF5), tint, .35)!,
          Color.lerp(tint, const Color(0xFF9FB289), .35)!,
        ]),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * .5, size.height * .16),
          size.width * .75,
          [const Color(0x99FFFFFF), const Color(0x00FFFFFF)],
        ),
    );

    // Plinth: walnut with a lit top edge and faint grain.
    final top = size.height * .77;
    final plinth = Rect.fromLTRB(0, top, size.width, size.height);
    canvas.drawRect(
      plinth,
      Paint()
        ..shader = ui.Gradient.linear(plinth.topCenter, plinth.bottomCenter, [
          const Color(0xFF7A5539),
          const Color(0xFF4B3325),
        ]),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, 2.5),
      Paint()..color = const Color(0xFFB08560),
    );
    final grain = Paint()
      ..color = const Color(0x14000000)
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final y = top + (size.height - top) * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 2), grain);
    }

    // Contact shadow on the plinth under the model.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, top + 2),
        width: size.width * .72,
        height: size.height * .07,
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CaseBackPainter old) => old.world != world;
}

final class _CaseFrontPainter extends CustomPainter {
  const _CaseFrontPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(28.0, size.shortestSide * .12);
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(r),
    );
    canvas.save();
    canvas.clipRRect(rrect);

    // Glass: faint milky film + two diagonal reflections.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0x0DFFFFFF),
    );
    final strip = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * .1, 0),
        Offset(size.width * .5, size.height * .5),
        [const Color(0x38FFFFFF), const Color(0x00FFFFFF)],
      );
    Path band(double x0, double w) => Path()
      ..moveTo(size.width * x0, 0)
      ..lineTo(size.width * (x0 + w), 0)
      ..lineTo(size.width * (x0 + w - .32), size.height * .78)
      ..lineTo(size.width * (x0 - .32), size.height * .78)
      ..close();
    canvas.drawPath(band(.36, .13), strip);
    canvas.drawPath(band(.56, .05), strip);

    // Brass lid: a thin rail along the top edge.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 6),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 6), [
          const Color(0xFFD9B878),
          const Color(0xFF8E6B34),
        ]),
    );
    canvas.restore();

    // Rim: lit on the upper left, in shade on the lower right.
    canvas.drawRRect(
      rrect.deflate(.75),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [const Color(0xB3FFFFFF), const Color(0x1F2E2B25)],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _CaseFrontPainter old) => false;
}

final class _Plaque extends StatelessWidget {
  const _Plaque(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8CB92), Color(0xFFB98F4E)],
      ),
      border: Border.all(color: const Color(0x66402A10)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: ExcludeSemantics(
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.6,
          color: Color(0xFF3B2814),
        ),
      ),
    ),
  );
}
