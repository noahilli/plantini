import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../catalog/presentation/widgets/world_lighting.dart';
import '../../../catalog/presentation/widgets/world_scene.dart';
import '../../domain/explorer.dart';

// Frontal-ish view for portraits: less squash than the level path.
const _squash = .30, _lift = .96;

void _paintExplorer(
  Canvas canvas,
  Size size,
  Explorer explorer,
  WorldLighting lighting,
  double yaw,
) {
  paintSkyBackdrop(canvas, size, lighting, const Color(0xFFE2E9DC));
  final scale = math.min(size.height * .80 / (1.35 * _lift), size.width / 1.15);
  final ox = size.width / 2;
  final feet = Offset(ox, size.height * .88);
  final oy = feet.dy + .1 * _lift * scale;
  final stage = Rect.fromCenter(
    center: feet,
    width: scale * 1.5,
    height: scale * .42,
  );
  canvas.drawOval(stage, Paint()..color = const Color(0xFF8FA774));
  canvas.drawOval(
    stage,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x40000000),
  );
  final vertices = SceneBuilder.build(
    [for (final mesh in explorer.meshes) SceneInstance(mesh)],
    SceneProjection(
      yaw: yaw,
      scale: scale,
      ox: ox,
      oy: oy,
      squash: _squash,
      lift: _lift,
    ),
    lighting: lighting,
  );
  if (vertices != null) {
    canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
    vertices.dispose();
  }
}

/// The explorer on a small stage under the current sky. Drag to turn it; it
/// sways a little on its own first (not under reduced motion).
class ExplorerStage extends StatefulWidget {
  const ExplorerStage({
    super.key,
    required this.explorer,
    this.interactive = true,
    this.borderRadius = 28,
  });

  final Explorer explorer;
  final bool interactive;
  final double borderRadius;

  @override
  State<ExplorerStage> createState() => _ExplorerStageState();
}

class _ExplorerStageState extends State<ExplorerStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  double _drag = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still =
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.of(context) ||
        !widget.interactive;
    if (still) {
      _sway.stop();
    } else if (!_sway.isAnimating && _sway.value == 0) {
      _sway.repeat(reverse: true, count: 4);
    }
  }

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${widget.explorer.name}, ${widget.explorer.blurb}',
    image: true,
    child: ListenableBuilder(
      listenable: DayClock.phase,
      builder: (context, _) => GestureDetector(
        onHorizontalDragUpdate: widget.interactive
            ? (d) => setState(
                () => _drag = (_drag + d.delta.dx * .012) % (math.pi * 2),
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sway,
              builder: (context, _) => CustomPaint(
                painter: _StagePainter(
                  widget.explorer,
                  WorldLighting.of(DayClock.phase.value),
                  _drag + math.sin((_sway.value - .5) * math.pi) * .45,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

final class _StagePainter extends CustomPainter {
  _StagePainter(this.explorer, this.lighting, this.yaw);

  final Explorer explorer;
  final WorldLighting lighting;
  final double yaw;

  @override
  void paint(Canvas canvas, Size size) =>
      _paintExplorer(canvas, size, explorer, lighting, yaw);

  @override
  bool shouldRepaint(_StagePainter old) =>
      old.explorer != explorer || old.lighting != lighting || old.yaw != yaw;
}

/// A resting portrait, baked once into a texture (per explorer, sky and size):
/// nine of them in a grid cost nine textured quads, not nine 1 000-triangle
/// scenes per frame.
class ExplorerPortrait extends StatelessWidget {
  const ExplorerPortrait({
    super.key,
    required this.explorer,
    this.borderRadius = 20,
  });

  final Explorer explorer;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: DayClock.phase,
    builder: (context, _) => ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        painter: _PortraitPainter(
          explorer,
          WorldLighting.of(DayClock.phase.value),
          MediaQuery.devicePixelRatioOf(context),
        ),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

final class _PortraitPainter extends CustomPainter {
  const _PortraitPainter(this.explorer, this.lighting, this.pixelRatio);

  final Explorer explorer;
  final WorldLighting lighting;
  final double pixelRatio;

  static final _images = <String, ui.Image>{};
  static final _retired = <ui.Image>[];
  static const _maxImages = 30;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final old in _retired) {
      old.dispose();
    }
    _retired.clear();
    final key =
        '${explorer.id}|${lighting.phase.name}|${size.width.round()}x${size.height.round()}|${pixelRatio.toStringAsFixed(2)}';
    var image = _images.remove(key);
    if (image == null) {
      if (_images.length >= _maxImages) {
        _retired.add(_images.remove(_images.keys.first)!);
      }
      final recorder = ui.PictureRecorder();
      final rec = Canvas(recorder)..scale(pixelRatio);
      _paintExplorer(rec, size, explorer, lighting, 0);
      final picture = recorder.endRecording();
      image = picture.toImageSync(
        (size.width * pixelRatio).ceil(),
        (size.height * pixelRatio).ceil(),
      );
      picture.dispose();
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
  bool shouldRepaint(_PortraitPainter old) =>
      old.explorer != explorer ||
      old.lighting != lighting ||
      old.pixelRatio != pixelRatio;
}
