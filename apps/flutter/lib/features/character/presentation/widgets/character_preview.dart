import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../catalog/presentation/widgets/world_lighting.dart';
import '../../../catalog/presentation/widgets/world_module.dart';
import '../../../catalog/presentation/widgets/world_scene.dart';
import '../../domain/character_spec.dart';
import 'character_kit.dart';

/// The character on a small stage under the current sky. Drag to turn it; it
/// sways a little on its own first (not under reduced motion).
class CharacterPreview extends StatefulWidget {
  const CharacterPreview({
    super.key,
    required this.spec,
    this.interactive = true,
    this.borderRadius = 28,
  });

  final CharacterSpec spec;
  final bool interactive;
  final double borderRadius;

  @override
  State<CharacterPreview> createState() => _CharacterPreviewState();
}

class _CharacterPreviewState extends State<CharacterPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  double _dragYaw = 0;

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
  Widget build(BuildContext context) {
    final kit = CharacterKit.loaded;
    return Semantics(
      label: 'Dein Charakter, Vorschau',
      image: true,
      child: ListenableBuilder(
        listenable: DayClock.phase,
        builder: (context, _) => GestureDetector(
          onHorizontalDragUpdate: widget.interactive
              ? (d) => setState(
                  () =>
                      _dragYaw = (_dragYaw + d.delta.dx * .012) % (math.pi * 2),
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: kit == null
                ? const SizedBox.expand()
                : AnimatedBuilder(
                    animation: _sway,
                    builder: (context, _) => CustomPaint(
                      painter: _StagePainter(
                        kit.build(widget.spec),
                        WorldLighting.of(DayClock.phase.value),
                        _dragYaw + math.sin((_sway.value - .5) * math.pi) * .45,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

final class _StagePainter extends CustomPainter {
  _StagePainter(this.meshes, this.lighting, this.yaw);

  final List<WorldMesh> meshes;
  final WorldLighting lighting;
  final double yaw;

  @override
  void paint(Canvas canvas, Size size) {
    paintSkyBackdrop(canvas, size, lighting, const Color(0xFFE2E9DC));
    // Character spans z = .1 .. 1.4; the stage ellipse sits under its feet.
    const squash = .30, lift = .96;
    final scale = math.min(size.height * .80 / (1.35 * lift), size.width / 1.6);
    final ox = size.width / 2;
    final oy = size.height * .86 + .1 * lift * scale;
    final feet = Offset(ox, size.height * .86);
    canvas.drawOval(
      Rect.fromCenter(center: feet, width: scale * 1.5, height: scale * .42),
      Paint()..color = const Color(0xFF8FA774),
    );
    canvas.drawOval(
      Rect.fromCenter(center: feet, width: scale * 1.5, height: scale * .42),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x40000000),
    );
    final vertices = SceneBuilder.build(
      [for (final mesh in meshes) SceneInstance(mesh)],
      SceneProjection(
        yaw: yaw,
        scale: scale,
        ox: ox,
        oy: oy,
        squash: squash,
        lift: lift,
      ),
      lighting: lighting,
    );
    if (vertices != null) {
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
      vertices.dispose();
    }
  }

  @override
  bool shouldRepaint(_StagePainter old) =>
      old.meshes != meshes || old.lighting != lighting || old.yaw != yaw;
}
