import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// How far the photo has come; each value is a real state of the workflow.
enum AnalysisStage { uploading, queued, analysing }

/// The waiting screen between "photo chosen" and "result": the photo with a
/// scanning beam, a turning ring and the steps that are actually happening.
class AnalysisProgress extends StatefulWidget {
  const AnalysisProgress({super.key, required this.stage, this.photo});

  final AnalysisStage stage;
  final Uint8List? photo;

  @override
  State<AnalysisProgress> createState() => _AnalysisProgressState();
}

class _AnalysisProgressState extends State<AnalysisProgress>
    with SingleTickerProviderStateMixin {
  static const _tips = [
    'Tipp: Blüte, Blatt und Wuchsform als getrennte Fotos verbessern die Bestimmung.',
    'Tipp: Bei gutem, weichem Licht erkennt die Bestimmung mehr Details.',
    'Tipp: Gehe nah ran, aber bleib scharf: ein Blatt oder eine Blüte füllt das Bild.',
    'Hinweis: Vorschläge sind keine Garantie. Du entscheidest, was du speicherst.',
  ];

  // Finite (~2.5 minutes) so widget tests can settle; an identification
  // normally takes a few seconds.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(count: 60);
  Timer? _tipTimer;
  int _tip = 0;

  @override
  void initState() {
    super.initState();
    _tipTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) setState(() => _tip = (_tip + 1) % _tips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final title = switch (stage) {
      AnalysisStage.uploading => 'Dein Foto wird hochgeladen',
      AnalysisStage.queued => 'Gleich geht es los',
      AnalysisStage.analysing => 'Die Pflanze wird bestimmt',
    };
    return Semantics(
      liveRegion: true,
      label: title,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 230,
            height: 230,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _RingPainter(_controller.value),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: _PhotoWithBeam(
                      photo: widget.photo,
                      progress: _controller.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              title,
              key: ValueKey(title),
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontSize: 25,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _Steps(stage: stage, spin: _controller),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SizedBox(
              height: 44,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _tips[_tip],
                  key: ValueKey(_tip),
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoWithBeam extends StatelessWidget {
  const _PhotoWithBeam({required this.photo, required this.progress});

  final Uint8List? photo;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Beam sweeps down and back up.
    final t = (math.sin(progress * 2 * math.pi - math.pi / 2) + 1) / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photo != null)
            Image.memory(
              photo!,
              fit: BoxFit.cover,
              cacheWidth: 400,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const _LeafBackdrop(),
            )
          else
            const _LeafBackdrop(),
          ColoredBox(color: AppColors.sage900.withValues(alpha: .18)),
          Align(
            alignment: Alignment(0, -1 + 2 * t),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.sage200.withValues(alpha: 0),
                      AppColors.sage200.withValues(alpha: .75),
                      AppColors.sage200.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafBackdrop extends StatelessWidget {
  const _LeafBackdrop();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.sage600,
    child: Center(
      child: Icon(Icons.eco_rounded, size: 64, color: AppColors.sage200),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = AppColors.sage200;
    canvas.drawCircle(center, radius, track);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..shader = SweepGradient(
        colors: const [
          Color(0x00558B2F),
          AppColors.sage600,
          AppColors.terracotta,
        ],
        stops: const [0, .7, 1],
        transform: GradientRotation(t * 2 * math.pi - math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(
      rect,
      t * 2 * math.pi - math.pi / 2 - 1.9,
      1.9,
      false,
      sweep,
    );
    // Three leaves ride the ring.
    for (var i = 0; i < 3; i++) {
      final a = t * 2 * math.pi + i * 2 * math.pi / 3 - math.pi / 2;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius;
      canvas.drawCircle(
        p,
        5 + 1.5 * math.sin(a * 2),
        Paint()..color = AppColors.sage600,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

class _Steps extends StatelessWidget {
  const _Steps({required this.stage, required this.spin});

  final AnalysisStage stage;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Foto hochladen',
      'Auf die Bestimmung warten',
      'Pflanze vergleichen',
    ];
    final current = stage.index;
    return Column(
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: i < current
                      ? const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.sage600,
                        )
                      : i == current
                      ? RotationTransition(
                          turns: spin,
                          child: const Icon(
                            Icons.autorenew_rounded,
                            size: 20,
                            color: AppColors.terracotta,
                          ),
                        )
                      : const Icon(
                          Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: AppColors.neutral400,
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  labels[i],
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: i <= current ? AppColors.ink : AppColors.neutral500,
                    fontWeight: i == current ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
