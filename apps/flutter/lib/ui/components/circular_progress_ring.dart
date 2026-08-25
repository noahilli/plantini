import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CircularProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;

  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 62,
  });

  @override
  Widget build(BuildContext context) {
    final percentText = '${(progress * 100).toInt()}%';

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress),
        child: Center(
          child: Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: const BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              percentText,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc with Sun yellow color
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final progressPaint = Paint()
      ..color = AppColors.sun
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
      )
      ..close();

    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
