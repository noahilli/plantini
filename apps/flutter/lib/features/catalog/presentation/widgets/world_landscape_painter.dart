import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Original vector scenery: a forest, meadow or mountain trail.
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
    final alpine = slug.contains('alpin') || slug.contains('berg');
    final meadow = slug.contains('meadow') || slug.contains('wiese');
    final paint = Paint();
    canvas.drawRect(
      Offset.zero & size,
      paint
        ..color = alpine
            ? const Color(0xFFE8EDE3)
            : meadow
            ? const Color(0xFFEDF0D4)
            : const Color(0xFFE1E9D3),
    );
    for (var i = 0; i < centers.length; i++) {
      final y = centers[i].dy;
      final x = centers[i].dx > size.width / 2 ? 30.0 : size.width - 34;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y + 24), width: 66, height: 20),
        paint..color = AppColors.sage400.withValues(alpha: .3),
      );
      if (alpine) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 26, y + 20)
            ..lineTo(x, y - 36)
            ..lineTo(x + 29, y + 20)
            ..close(),
          paint..color = AppColors.sage400,
        );
        canvas.drawPath(
          Path()
            ..moveTo(x - 9, y - 16)
            ..lineTo(x, y - 36)
            ..lineTo(x + 10, y - 16)
            ..close(),
          paint..color = AppColors.neutral100,
        );
      } else if (meadow) {
        for (var flower = 0; flower < 3; flower++) {
          final fx = x - 15 + flower * 15;
          final top = y - (flower.isEven ? 6 : 20);
          canvas.drawLine(
            Offset(fx, y + 20),
            Offset(fx, top),
            paint
              ..color = AppColors.sage600
              ..strokeWidth = 3,
          );
          for (var petal = 0; petal < 5; petal++) {
            canvas.drawCircle(
              Offset(
                fx + math.cos(petal * 1.257) * 5,
                top + math.sin(petal * 1.257) * 5,
              ),
              4,
              paint
                ..color = i.isEven ? AppColors.neutral100 : AppColors.accent300,
            );
          }
          canvas.drawCircle(
            Offset(fx, top),
            3,
            paint..color = AppColors.terracotta,
          );
        }
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 4, y - 10, 8, 35),
            const Radius.circular(3),
          ),
          paint..color = AppColors.accent700,
        );
        for (var tier = 0; tier < 3; tier++) {
          final top = y - 51 + tier * 17;
          final half = 16.0 + tier * 5;
          canvas.drawPath(
            Path()
              ..moveTo(x, top)
              ..lineTo(x + half, top + 32)
              ..quadraticBezierTo(x, top + 40, x - half, top + 32)
              ..close(),
            paint..color = tier.isEven ? AppColors.sage600 : AppColors.sage500,
          );
        }
      }
      for (var dot = 0; dot < 5; dot++) {
        canvas.drawCircle(
          Offset((dot * 73.0 + i * 29) % size.width, y + 80),
          2,
          paint..color = AppColors.sage500.withValues(alpha: .4),
        );
      }
    }
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
          ..strokeWidth = 25
          ..color = AppColors.neutral400.withValues(alpha: .45),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 19
          ..color = completed[i - 1] ? AppColors.accent300 : AppColors.bg,
      );
      final metric = path.computeMetrics().first;
      for (var distance = 12.0; distance < metric.length; distance += 20) {
        canvas.drawCircle(
          metric.getTangentForOffset(distance)!.position,
          2,
          Paint()..color = AppColors.accent700.withValues(alpha: .3),
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
