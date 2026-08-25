import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Stylized botanical artwork widget matching the HTML design specification
class PlantArtWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const PlantArtWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF183C31),
            Color(0xFF4B765C),
            Color(0xFFB3B997),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background organic curves
          Positioned.fill(
            child: CustomPaint(
              painter: _BotanicalBackgroundPainter(),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _BotanicalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x3380A276)
      ..style = PaintingStyle.fill;

    // Large background leaf 1
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.9,
    );
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height,
      0,
      size.height * 0.7,
    );
    canvas.drawPath(path1, paint);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFFDFE5C8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(size.width * 0.48, size.height * 0.9);
    stemPath.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.5,
      size.width * 0.46,
      size.height * 0.2,
    );
    canvas.drawPath(stemPath, stemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF7CA273)
      ..style = PaintingStyle.fill;

    // Left leaf
    final leaf1 = Path();
    leaf1.moveTo(size.width * 0.5, size.height * 0.55);
    leaf1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.3,
      size.height * 0.35,
    );
    leaf1.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.45,
      size.width * 0.5,
      size.height * 0.55,
    );
    canvas.drawPath(leaf1, leafPaint);

    // Right leaf
    final leaf2 = Path();
    leaf2.moveTo(size.width * 0.5, size.height * 0.42);
    leaf2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width * 0.7,
      size.height * 0.25,
    );
    leaf2.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.42,
    );
    canvas.drawPath(leaf2, leafPaint);

    // Flower blossom petals
    final flowerPaint = Paint()..color = AppColors.white;
    final flowerCenter = Offset(size.width * 0.46, size.height * 0.2);
    canvas.drawCircle(flowerCenter, 7, flowerPaint);
    canvas.drawCircle(flowerCenter.translate(8, 2), 6, flowerPaint);
    canvas.drawCircle(flowerCenter.translate(-6, 6), 6, Paint()..color = const Color(0xFFF8F5DD));
    canvas.drawCircle(flowerCenter.translate(5, 9), 6, flowerPaint);
    canvas.drawCircle(flowerCenter.translate(2, 4), 4, Paint()..color = AppColors.sun);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
