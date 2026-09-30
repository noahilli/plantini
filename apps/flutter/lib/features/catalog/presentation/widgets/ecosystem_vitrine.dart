import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/diagnostics/frame_stats.dart';
import 'modular_forest_view.dart' show EcosystemWorld;
import '../../../character/presentation/widgets/character_kit.dart';
import 'world_lighting.dart';
import 'world_module.dart';
import 'world_scene.dart';

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
    return ListenableBuilder(
      listenable: Listenable.merge([DayClock.phase, PlayerLook.spec]),
      builder: (context, _) => _buildFor(context, DayClock.phase.value),
    );
  }

  Widget _buildFor(BuildContext context, DayPhase phase) {
    final lighting = WorldLighting.of(phase);
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
              final pixelRatio = MediaQuery.devicePixelRatioOf(context);
              return Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<WorldModule>(
                    future: _module,
                    builder: (context, snapshot) {
                      final module = snapshot.data;
                      if (!widget.animate && module != null) {
                        // Resting vitrine: one baked texture (see _BakedCasePainter).
                        return CustomPaint(
                          size: size,
                          isComplex: true,
                          willChange: false,
                          painter: _BakedCasePainter(
                            world,
                            module,
                            widget.yaw,
                            pixelRatio,
                            lighting,
                          ),
                        );
                      }
                      // Animated (or still loading): layered case, the model
                      // stepping through cached angles.
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(
                            isComplex: true,
                            willChange: false,
                            painter: _CaseBackPainter(world, lighting),
                          ),
                          if (module != null)
                            CustomPaint(
                              size: size,
                              isComplex: true,
                              willChange: true,
                              painter: _MiniWorldPainter(
                                module,
                                world.asset,
                                _step,
                                _bucket,
                                pixelRatio: pixelRatio,
                                asImage: false,
                                lighting: lighting,
                              ),
                            ),
                          const CustomPaint(
                            isComplex: true,
                            willChange: false,
                            painter: _CaseFrontPainter(),
                          ),
                        ],
                      );
                    },
                  ),
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

/// Replays cached pictures; recording only happens on a cache miss.
final class _MiniWorldPainter extends CustomPainter {
  _MiniWorldPainter(
    this.module,
    this.asset,
    this.step,
    this.bucket, {
    required this.pixelRatio,
    required this.asImage,
    required this.lighting,
  }) : super(repaint: step);

  final WorldModule module;
  final String asset;
  final ValueNotifier<int> step;
  final double bucket;
  final double pixelRatio;
  final WorldLighting lighting;

  /// Resting vitrines are rasterised once into a GPU texture: scrolling then
  /// costs a textured quad instead of re-drawing ~19k triangles per vitrine
  /// every frame (measured: ~2 ms/frame on a desktop GPU for seven vitrines,
  /// a multiple of that on phone GPUs). The swaying hero stays a picture: its
  /// many angles as full-size textures would cost too much memory.
  final bool asImage;

  // ui.Picture or ui.Image, most recently used last.
  static final _cache = <String, Object>{};
  static final _retired = <Object>[];
  static const _maxEntries = 40;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final old in _retired) {
      if (old is ui.Image) old.dispose();
      if (old is ui.Picture) old.dispose();
    }
    _retired.clear();
    final key =
        '$asset|${lighting.phase.name}|${PlayerLook.cacheKey}|${step.value}|${size.width.round()}x${size.height.round()}|'
        '${asImage ? 'i${pixelRatio.toStringAsFixed(2)}' : 'p'}';
    var entry = _cache.remove(key); // re-insert below: most recent last
    if (entry == null) {
      if (_cache.length >= _maxEntries) {
        _retired.add(_cache.remove(_cache.keys.first)!);
      }
      final timer = Stopwatch()..start();
      final picture = _record(
        size,
        step.value * bucket,
        asImage ? pixelRatio : 1,
      );
      if (asImage) {
        entry = picture.toImageSync(
          (size.width * pixelRatio).ceil(),
          (size.height * pixelRatio).ceil(),
        );
        picture.dispose();
      } else {
        entry = picture;
      }
      FrameStats.note('vitrine-record', timer.elapsed);
    }
    _cache[key] = entry;
    if (entry is ui.Image) {
      canvas.drawImageRect(
        entry,
        Rect.fromLTWH(0, 0, entry.width.toDouble(), entry.height.toDouble()),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      canvas.drawPicture(entry as ui.Picture);
    }
  }

  ui.Picture _record(Size size, double yaw, double scale) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    if (scale != 1) canvas.scale(scale);
    _drawModel(canvas, module, yaw, size, lighting);
    return recorder.endRecording();
  }

  @override
  bool shouldRepaint(covariant _MiniWorldPainter old) =>
      old.module != module ||
      old.asset != asset ||
      old.pixelRatio != pixelRatio ||
      old.lighting != lighting ||
      old.asImage != asImage;
}

/// Projects and paints the miniature into [canvas] for the given angle.
void _drawModel(
  Canvas canvas,
  WorldModule module,
  double yaw,
  Size size,
  WorldLighting lighting,
) {
  final fit = _Fit(module, yaw, size);
  final instances = <SceneInstance>[
    for (final mesh in PlayerLook.meshesFor(module))
      // Level stations belong to the path view, not to a display piece.
      if (mesh.slot == null)
        SceneInstance(
          mesh,
          // The explorer stands at the first station.
          dx: mesh.motion == 'ranger' ? module.slots.first[0] + .65 : 0,
          dy: mesh.motion == 'ranger' ? module.slots.first[1] - .2 : 0,
        ),
  ];
  final vertices = SceneBuilder.build(
    instances,
    SceneProjection(
      yaw: yaw,
      scale: fit.scale,
      ox: fit.origin.dx,
      oy: fit.origin.dy,
    ),
    shading: SceneShading.viewer,
    lighting: lighting,
  );
  if (vertices != null) {
    canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
    vertices.dispose();
  }
}

/// A resting vitrine (back wall, plinth, model, glass) baked into ONE texture.
/// Scrolling a list of them then costs one textured quad each, instead of
/// replaying gradients, clips and a blurred shadow per vitrine per frame.
final class _BakedCasePainter extends CustomPainter {
  const _BakedCasePainter(
    this.world,
    this.module,
    this.yaw,
    this.pixelRatio,
    this.lighting,
  );

  final EcosystemWorld world;
  final WorldModule module;
  final double yaw, pixelRatio;
  final WorldLighting lighting;

  static final _images = <String, ui.Image>{};
  static final _retired = <ui.Image>[];
  static const _maxImages = 24;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final old in _retired) {
      old.dispose();
    }
    _retired.clear();
    final key =
        '${world.asset}|${lighting.phase.name}|${PlayerLook.cacheKey}|${yaw.toStringAsFixed(3)}|${size.width.round()}x${size.height.round()}|${pixelRatio.toStringAsFixed(2)}';
    var image = _images.remove(key);
    if (image == null) {
      if (_images.length >= _maxImages) {
        _retired.add(_images.remove(_images.keys.first)!);
      }
      final timer = Stopwatch()..start();
      final recorder = ui.PictureRecorder();
      final rec = Canvas(recorder)..scale(pixelRatio);
      _CaseBackPainter(world, lighting).paint(rec, size);
      _drawModel(rec, module, yaw, size, lighting);
      const _CaseFrontPainter().paint(rec, size);
      final picture = recorder.endRecording();
      image = picture.toImageSync(
        (size.width * pixelRatio).ceil(),
        (size.height * pixelRatio).ceil(),
      );
      picture.dispose();
      FrameStats.note('vitrine-bake', timer.elapsed);
    }
    _images[key] = image;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _BakedCasePainter old) =>
      old.world != world ||
      old.module != module ||
      old.yaw != yaw ||
      old.lighting != lighting ||
      old.pixelRatio != pixelRatio;
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
}

// ---------------------------------------------------------------------------
// Case: back wall + plinth behind the model, glass + brass in front of it.

final class _CaseBackPainter extends CustomPainter {
  const _CaseBackPainter(this.world, this.lighting);
  final EcosystemWorld world;
  final WorldLighting lighting;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(28.0, size.shortestSide * .12);
    final clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(r),
    );
    canvas.save();
    canvas.clipRRect(clip);

    // Back wall: a soft, slightly tinted gallery light; the sky colour and the
    // sun or moon glow follow the time of day.
    final tint = world.background;
    final noon = lighting.phase == DayPhase.noon;
    final (skyTop, skyBottom) = lighting.backdrop(tint);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
          noon ? Color.lerp(const Color(0xFFFFFCF5), tint, .35)! : skyTop,
          noon ? Color.lerp(tint, const Color(0xFF9FB289), .35)! : skyBottom,
        ]),
    );
    final glowAt = Offset(
      size.width * (.5 + (noon ? 0 : lighting.glowAt.x) * .42),
      size.height * (noon ? .16 : .5 + lighting.glowAt.y * .36),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(glowAt, size.width * .75, [
          noon ? const Color(0x99FFFFFF) : lighting.glow.withValues(alpha: .6),
          const Color(0x00FFFFFF),
        ]),
    );
    if (lighting.stars) {
      paintStars(canvas, Size(size.width, size.height * .8), 16);
    }

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
  bool shouldRepaint(covariant _CaseBackPainter old) =>
      old.world != world || old.lighting != lighting;
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
