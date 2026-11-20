import 'dart:math';
import 'package:flutter/material.dart';

/// رسم زخرفة إسلامية هندسية (نجمة ثمانية متكررة) بالكود بالكامل —
/// مستوحاة من الإطار الهندسي الموجود أسفل الصورة الأصلية.
/// تُستخدم كإطار زخرفي علوي/سفلي حول محتوى الشاشة.
class IslamicPatternPainter extends CustomPainter {
  IslamicPatternPainter({required this.color, this.tileSize = 34});

  final Color color;
  final double tileSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final cols = (size.width / tileSize).ceil() + 1;
    final rows = (size.height / tileSize).ceil() + 1;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final center = Offset(c * tileSize, r * tileSize);
        _drawEightPointStar(canvas, paint, center, tileSize * 0.46);
      }
    }
  }

  void _drawEightPointStar(
      Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    const points = 8;
    for (var i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : radius * 0.42;
      final angle = (pi / points) * i - pi / 2;
      final offset =
          Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.tileSize != tileSize;
}
