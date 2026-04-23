import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
    paint_0.shader = ui.Gradient.linear(
        Offset(size.width * 0.64, size.height * 0.11),
        Offset(size.width, size.height * 0.11),
        [Color(0x55e17e51), Color(0x99cd5c0b)],
        [0.00, 1.00]);

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.64, 0);
    path_0.quadraticBezierTo(size.width * 0.74, size.height * 0.09,
        size.width * 0.79, size.height * 0.08);
    path_0.cubicTo(size.width * 0.74, size.height * 0.09, size.width * 0.69,
        size.height * 0.14, size.width * 0.71, size.height * 0.17);
    path_0.quadraticBezierTo(size.width * 0.72, size.height * 0.19,
        size.width * 0.79, size.height * 0.21);
    path_0.quadraticBezierTo(
        size.width * 0.93, size.height * 0.24, size.width, size.height * 0.21);
    path_0.quadraticBezierTo(size.width, size.height * 0.16, size.width, 0);
    path_0.lineTo(size.width * 0.64, 0);
    path_0.close();

    canvas.drawPath(path_0, paint_0);

    Paint paint_1 = new Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
    paint_1.shader = ui.Gradient.linear(
        Offset(size.width * 0.64, size.height * 0.12),
        Offset(size.width, size.height * 0.12),
        [Color(0x6ade8146), Color(0x87b75b0a)],
        [0.00, 1.00]);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.64, size.height * 0.08);
    path_1.quadraticBezierTo(size.width * 0.68, size.height * 0.15,
        size.width * 0.76, size.height * 0.13);
    path_1.cubicTo(size.width * 0.81, size.height * 0.15, size.width * 0.71,
        size.height * 0.22, size.width * 0.74, size.height * 0.24);
    path_1.quadraticBezierTo(
        size.width * 0.81, size.height * 0.27, size.width, size.height * 0.18);
    path_1.lineTo(size.width, 0);
    path_1.quadraticBezierTo(size.width * 0.83, 0, size.width * 0.77, 0);
    path_1.quadraticBezierTo(size.width * 0.66, size.height * 0.02,
        size.width * 0.64, size.height * 0.08);
    path_1.close();

    canvas.drawPath(path_1, paint_1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

