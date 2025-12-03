import 'package:flutter/material.dart';

/// رسام SVG لموجات في بطاقة الرصيد
class WavePainter extends CustomPainter {
  final Color color;
  final double opacity;

  WavePainter({this.color = Colors.white, this.opacity = 0.2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();

    // بداية المسار من اليسار
    path.moveTo(0, size.height * 0.4);

    // موجة أولى
    path.quadraticBezierTo(
      size.width * 0.25, // control point x
      size.height * 0.2, // control point y
      size.width * 0.5, // end point x
      size.height * 0.4, // end point y
    );

    // موجة ثانية
    path.quadraticBezierTo(
      size.width * 0.75, // control point x
      size.height * 0.6, // control point y
      size.width, // end point x
      size.height * 0.4, // end point y
    );

    // إكمال المسار للأسفل واليسار
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
