import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Draws only the navigable trail over the generated world artwork.
final class WorldLandscapePainter extends CustomPainter {
  const WorldLandscapePainter({
    required this.centers,
    required this.slug,
    required this.completed,
  });
  final List<Offset> centers;
  final List<bool> completed;
  final String slug;
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 1; i < centers.length; i++) {
      final from = centers[i - 1];
      final to = centers[i];
      final middle = (from.dy + to.dy) / 2;
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(from.dx, middle, to.dx, middle, to.dx, to.dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 28
          ..color = AppColors.sage900.withValues(alpha: .22),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 20
          ..color = completed[i - 1]
              ? AppColors.accent300.withValues(alpha: .94)
              : AppColors.neutral100.withValues(alpha: .88),
      );
      final metric = path.computeMetrics().first;
      for (var distance = 12.0; distance < metric.length; distance += 20) {
        canvas.drawCircle(
          metric.getTangentForOffset(distance)!.position,
          2,
          Paint()..color = AppColors.sage800.withValues(alpha: .3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WorldLandscapePainter oldDelegate) =>
      slug != oldDelegate.slug ||
      !listEquals(centers, oldDelegate.centers) ||
      !listEquals(completed, oldDelegate.completed);
}
