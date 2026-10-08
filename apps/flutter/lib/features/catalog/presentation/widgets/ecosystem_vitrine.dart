import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/diagnostics/frame_stats.dart';
import 'modular_forest_view.dart' show EcosystemWorld;
import '../../../character/presentation/widgets/explorer_roster.dart';
import 'world_lighting.dart';
import 'world_module.dart';
import 'world_scene.dart';

/// A miniature of an ecosystem that floats in front of whatever is behind it,
/// like the three models on the project homepage: the same module as the level
/// path, a soft shadow under it, no case, no glass, no plinth. (The widget keeps
/// its old name "Vitrine" so that callers and tests need not change.)
///
/// Cost model: the miniature is projected and lit once per (world, angle,
/// size) and then replayed as a bounded cached texture. Static models therefore
/// never repaint. With [animate] the model sways a few degrees and hovers up
/// and down for two slow swings (stepping through a handful of cached angles)
/// and then rests; it does not move at all under reduced motion or while the
/// widget is not ticking (off-screen tab).
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
  static const _swing = .15; // radians either side of [yaw] while animating
  static const _bucket = .045; // ≈2.6°: angles the cache is keyed on

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
      listenable: Listenable.merge([DayClock.phase, PlayerLook.id]),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final pixelRatio = math.min(
                    MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0),
                    1024 / size.longestSide,
                  );
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      FutureBuilder<WorldModule>(
                        future: _module,
                        builder: (context, snapshot) {
                          final module = snapshot.data;
                          if (module == null) {
                            // Still loading: nothing yet.
                            return const SizedBox.expand();
                          }
                          // The model is baked into one texture per angle and
                          // replayed as a textured quad. While it sways it steps
                          // through a handful of such textures; layered painters
                          // (blurred shadows, gradients) cost 10-30 ms per frame
                          // while scrolling. The hover is only an offset of the
                          // texture, the shadow a single radial gradient.
                          return ValueListenableBuilder<int>(
                            valueListenable: _step,
                            builder: (context, step, _) => CustomPaint(
                              size: size,
                              isComplex: true,
                              willChange: false,
                              painter: _FloatingModelPainter(
                                world,
                                module,
                                widget.animate ? step * _bucket : widget.yaw,
                                pixelRatio,
                                lighting,
                                widget.animate ? _clock : null,
                              ),
                            ),
                          );
                        },
                      ),
                      if (widget.title != null)
                        Align(
                          alignment: const Alignment(0, .93),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _NameTag(widget.title!),
                          ),
                        ),
                      if (widget.child != null) widget.child!,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Miniature

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
      if (mesh.slot == null &&
          mesh.inVariant(0) &&
          !(mesh.dayOnly && lighting.phase == DayPhase.night))
        SceneInstance(
          mesh,
          // The explorer stands at the first station.
          dx: mesh.motion == 'ranger' ? module.slots.first[0] + .65 : 0,
          dy: mesh.motion == 'ranger' ? module.slots.first[1] - .2 : 0,
        ),
  ];
  final projection = SceneProjection(
    yaw: yaw,
    scale: fit.scale,
    ox: fit.origin.dx,
    oy: fit.origin.dy,
  );
  SceneBuilder.paintScene(
    canvas,
    instances,
    projection,
    shading: SceneShading.viewer,
    lighting: lighting,
    // The glow of a lamp sits at its depth: what stands in front hides it.
    markers: lightMarkers(module.lightsOf(0), projection, lighting, size),
  );
  final fireflies = module.fireflies;
  if (fireflies != null && lighting.lamps) {
    // A still picture: a handful of fireflies caught mid-flight.
    paintFireflies(
      canvas,
      fireflies,
      projection.project,
      fit.scale,
      .35,
      share: lighting.phase == DayPhase.night ? .75 : .3,
    );
  }
}

/// A resting model baked into ONE texture. Scrolling a list of them then costs
/// one textured quad each, instead of replaying projections and gradients per
/// model per frame. The soft shadow under the model is one radial gradient; the
/// hover moves the texture and squeezes the shadow, nothing is re-baked.
final class _FloatingModelPainter extends CustomPainter {
  _FloatingModelPainter(
    this.world,
    this.module,
    this.yaw,
    this.pixelRatio,
    this.lighting,
    this.hover,
  ) : super(repaint: hover);

  final EcosystemWorld world;
  final WorldModule module;
  final double yaw, pixelRatio;
  final WorldLighting lighting;

  /// 0..1 loop of the hover while the model animates, otherwise null.
  final Animation<double>? hover;

  static final _images = <String, ui.Image>{};
  static final _retired = <ui.Image>[];
  // At most twelve 1024px textures, rather than desktop-sized GPU surfaces.
  static const _maxImages = 12;

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
      _drawModel(rec, module, yaw, size, lighting);
      final picture = recorder.endRecording();
      image = picture.toImageSync(
        (size.width * pixelRatio).ceil(),
        (size.height * pixelRatio).ceil(),
      );
      picture.dispose();
      FrameStats.note('vitrine-bake', timer.elapsed);
    }
    _images[key] = image;

    // Hover: two slow rises and falls over the animation loop; at rest 0.
    final loop = hover?.value ?? 0;
    final lift = math.sin(loop * math.pi * 4) * size.height * .014;
    // Soft shadow on the ground under the model, smaller while it rises.
    final shadowCentre = Offset(size.width * .5, size.height * .80);
    final shadowWidth = size.width * (.62 - lift / size.height * 3);
    final shadowHeight = size.height * .075;
    final shadow = Rect.fromCenter(
      center: shadowCentre,
      width: shadowWidth,
      height: shadowHeight,
    );
    canvas.drawOval(
      shadow,
      Paint()
        ..shader = ui.Gradient.radial(
          shadowCentre,
          shadowWidth / 2,
          const [Color(0x40000000), Color(0x00000000)],
          null,
          TileMode.clamp,
          // Squash the circle into an ellipse.
          Float64List.fromList([
            1, 0, 0, 0, //
            0, shadowHeight / shadowWidth, 0, 0,
            0, 0, 1, 0,
            0, shadowCentre.dy * (1 - shadowHeight / shadowWidth), 0, 1,
          ]),
        ),
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      (Offset.zero & size).shift(Offset(0, -lift)),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _FloatingModelPainter old) =>
      old.world != world ||
      old.module != module ||
      old.yaw != yaw ||
      old.lighting != lighting ||
      old.pixelRatio != pixelRatio;
}

/// Fit-to-bounds projection: the module's bounding box is projected at the
/// given angle and scaled into the free area above the shadow and the name tag.
final class _Fit {
  _Fit(WorldModule module, this.yaw, Size size) {
    var minX = 1e9, maxX = -1e9, minY = 1e9, maxY = -1e9;
    var minZ = 1e9, maxZ = -1e9;
    for (final mesh in module.meshes) {
      if (mesh.slot != null || !mesh.inVariant(0)) continue;
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
    // Free area: margins left/right/top, room for shadow and name tag below.
    final area = Rect.fromLTWH(
      size.width * .03,
      size.height * .03,
      size.width * .94,
      size.height * .74,
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

/// The name of the world in a soft pill under the floating model.
final class _NameTag extends StatelessWidget {
  const _NameTag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      color: const Color(0xE6FFFBF2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ExcludeSemantics(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF2E2B25),
          ),
        ),
      ),
    ),
  );
}
