import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A decorative, vector specimen. [collected] must come from a confirmed taxon
/// match; this widget makes no claim about server-authoritative level progress.
/// The scientific name (or common name) seeds stable botanical variation.
class PlantSpecimenBottle extends StatelessWidget {
  const PlantSpecimenBottle({
    super.key,
    required this.collected,
    this.plantName,
    this.scientificName,
    this.height = 150,
  }) : assert(height > 0 && height < double.infinity);

  final bool collected;
  final String? plantName;
  final String? scientificName;
  final double height;

  @override
  Widget build(BuildContext context) {
    final species = (scientificName?.trim().isNotEmpty ?? false)
        ? scientificName!.trim().toLowerCase()
        : (plantName ?? '').trim().toLowerCase();
    return Semantics(
      image: true,
      label:
          '${plantName ?? scientificName ?? 'Pflanze'}: '
          '${collected ? 'Pflanze im Glas' : 'Leeres Glas, noch nicht gesammelt'}',
      child: SizedBox(
        height: height,
        width: height * .76,
        child: CustomPaint(
          painter: _BottlePainter(collected: collected, species: species),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  const _BottlePainter({required this.collected, required this.species});

  final bool collected;
  final String species;

  // Unlike String.hashCode, this seed is stable across devices and launches.
  int get _seed =>
      species.codeUnits.fold(17, (a, b) => (a * 31 + b) & 0x7fffffff);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width / 114, size.height / 150);
    canvas.translate(
      (size.width - 114 * scale) / 2,
      (size.height - 150 * scale) / 2,
    );
    canvas.scale(scale);
    final paint = Paint()..isAntiAlias = true;
    canvas.drawOval(
      const Rect.fromLTWH(19, 139, 76, 8),
      paint..color = const Color(0x183B5144),
    );
    final glass = Path()
      ..moveTo(43, 21)
      ..lineTo(43, 35)
      ..cubicTo(43, 44, 22, 43, 21, 61)
      ..lineTo(18, 126)
      ..quadraticBezierTo(18, 141, 34, 141)
      ..lineTo(80, 141)
      ..quadraticBezierTo(96, 141, 96, 126)
      ..lineTo(93, 61)
      ..cubicTo(92, 43, 71, 44, 71, 35)
      ..lineTo(71, 21)
      ..close();
    canvas.drawPath(
      glass,
      paint
        ..shader = const LinearGradient(
          colors: [Color(0x458CAFAD), Color(0x22FFFFFF), Color(0x669DBAB0)],
          stops: [0, .44, 1],
        ).createShader(const Rect.fromLTWH(18, 21, 78, 120)),
    );
    paint.shader = null;
    canvas.save();
    canvas.clipPath(glass);
    canvas.drawOval(
      const Rect.fromLTWH(25, 126, 64, 10),
      paint..color = const Color(0x447C9A83),
    );
    if (collected) _drawSpecimen(canvas);
    // Reflections sit over the specimen, giving the glass a tangible surface.
    paint
      ..color = const Color(0xAAFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(32, 57)
        ..quadraticBezierTo(27, 63, 28, 80)
        ..lineTo(26, 113),
      paint,
    );
    canvas.drawLine(const Offset(27, 120), const Offset(27, 124), paint);
    canvas.drawPath(
      Path()
        ..moveTo(83, 65)
        ..lineTo(86, 121),
      paint
        ..color = const Color(0x55FFFFFF)
        ..strokeWidth = 1.5,
    );
    canvas.restore();
    canvas.drawPath(
      glass,
      paint
        ..color = const Color(0x99768F82)
        ..strokeWidth = 1.2,
    );
    canvas.drawArc(
      const Rect.fromLTWH(23, 125, 68, 11),
      0,
      math.pi,
      false,
      paint..color = const Color(0x99748F80),
    );
    paint.style = PaintingStyle.fill;
    // The cork has a bevel, grain, and an elliptical top.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 9, 26, 18),
        const Radius.circular(4),
      ),
      paint
        ..shader = const LinearGradient(
          colors: [Color(0xFFC59B70), Color(0xFF9B7050)],
        ).createShader(const Rect.fromLTWH(44, 9, 26, 18)),
    );
    paint.shader = null;
    canvas.drawOval(
      const Rect.fromLTWH(44, 7, 26, 6),
      paint..color = const Color(0xFFDAB991),
    );
    for (var i = 0; i < 7; i++) {
      canvas.drawLine(
        Offset(47.0 + (i * 7 % 19), 15.0 + (i * 3 % 8)),
        Offset(49.0 + (i * 7 % 19), 15.0 + (i * 3 % 8)),
        paint
          ..color = const Color(0x887C573D)
          ..strokeWidth = .8,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 24, 34, 7),
        const Radius.circular(3),
      ),
      paint..color = const Color(0x66D7E7DB),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 24, 34, 7),
        const Radius.circular(3),
      ),
      paint
        ..style = PaintingStyle.stroke
        ..color = const Color(0x99768F82)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      const Offset(44, 25),
      const Offset(66, 25),
      paint..color = const Color(0xCCFFFFFF),
    );
    canvas.restore();
  }

  void _drawSpecimen(Canvas canvas) {
    final seed = _seed;
    final flowering = seed % 3 != 0;
    final lean = (seed % 11 - 5).toDouble();
    final top = Offset(57 + lean, flowering ? 65 : 56);
    final stem = Paint()
      ..color = const Color(0xFF496D49)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(56, 130)
        ..cubicTo(63, 111, 48, 88, top.dx, top.dy),
      stem,
    );
    final leaves = 3 + seed % 3;
    for (var i = 0; i < leaves; i++) {
      final y = 119.0 - i * 12;
      final direction = i.isEven ? -1.0 : 1.0;
      final origin = Offset(56, y);
      final tip = Offset(56 + direction * (15 + seed % 9), y - 13 - seed % 5);
      final leaf = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(tip.dx, y + 3, tip.dx, tip.dy)
        ..quadraticBezierTo(56, y - 17, origin.dx, origin.dy);
      canvas.drawPath(
        leaf,
        Paint()
          ..color = i.isEven
              ? const Color(0xFF638958)
              : const Color(0xFF8BA471),
      );
      canvas.drawLine(
        origin,
        tip,
        Paint()
          ..color = const Color(0x998CAE83)
          ..strokeWidth = .7,
      );
    }
    if (flowering) {
      const colors = [
        Color(0xFFCF8D77),
        Color(0xFFF6EEE0),
        Color(0xFFB19BC1),
        Color(0xFFDFBC61),
      ];
      final petals = 5 + seed % 4;
      final petalPaint = Paint()..color = colors[(seed ~/ 3) % colors.length];
      for (var i = 0; i < petals; i++) {
        canvas.save();
        canvas.translate(top.dx, top.dy);
        canvas.rotate(i * math.pi * 2 / petals);
        canvas.drawOval(
          Rect.fromLTWH(-3.6, -13, 7.2, 12.0 + seed % 3),
          petalPaint,
        );
        canvas.restore();
      }
      canvas.drawCircle(top, 4.5, Paint()..color = const Color(0xFFB58A3F));
      canvas.drawCircle(
        top - const Offset(1, 1),
        1.6,
        Paint()..color = const Color(0xFFF4D582),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) =>
      collected != oldDelegate.collected || species != oldDelegate.species;
}
