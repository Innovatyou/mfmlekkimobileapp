import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders the Higher Ground app logo using CustomPainter — no image assets
/// required. Composed of:
///   • Indigo gradient rounded-square background (#4338ca → #818cf8)
///   • Two layered mountain-peak triangles (white, semi-transparent)
///   • A solid-white cross at the summit
///
/// Usage:
///   AppLogo(size: 80)
///   AppLogo(size: 120, radius: 32)
class AppLogo extends StatelessWidget {
  final double size;
  final double? radius; // defaults to size * 0.25

  const AppLogo({Key? key, this.size = 80, this.radius}) : super(key: key);

  /// Renders the logo off-screen and returns it as an [ImageProvider].
  /// Useful for APIs that only accept [ImageProvider] (e.g. flutter_login).
  static Future<MemoryImage> toImageProvider({
    double size = 80,
    double? radius,
  }) async {
    final r = radius ?? size * 0.25;
    final recorder = ui.PictureRecorder();
    _LogoPainter(radius: r).paint(Canvas(recorder), Size(size, size));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.round(), size.round());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return MemoryImage(data!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(radius: radius ?? size * 0.25),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double radius;
  const _LogoPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // ── 1. Gradient background ──────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4338ca), Color(0xFF6366f1), Color(0xFF818cf8)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rRect, bgPaint);

    // Clip all subsequent drawing to the rounded rectangle
    canvas.save();
    canvas.clipRRect(rRect);

    // ── 2. Primary mountain peak ─────────────────────────────────────────────
    // Coordinates mirror the SVG viewBox (100×100 → normalised to w×h)
    final mountainPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final primaryPeak = Path()
      ..moveTo(w * 0.50, h * 0.24) // summit
      ..lineTo(w * 0.05, h * 0.82) // bottom-left
      ..lineTo(w * 0.95, h * 0.82) // bottom-right
      ..close();
    canvas.drawPath(primaryPeak, mountainPaint);

    // ── 3. Secondary mountain peak (adds depth) ──────────────────────────────
    final mountain2Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final secondaryPeak = Path()
      ..moveTo(w * 0.72, h * 0.38)
      ..lineTo(w * 0.45, h * 0.82)
      ..lineTo(w * 1.00, h * 0.82)
      ..close();
    canvas.drawPath(secondaryPeak, mountain2Paint);

    // ── 4. Cross at the summit ───────────────────────────────────────────────
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Vertical bar  (x=45.5%, y=5%, w=9%, h=22%)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.455, h * 0.05, w * 0.09, h * 0.22),
        const Radius.circular(3),
      ),
      crossPaint,
    );

    // Horizontal bar  (x=35%, y=13%, w=30%, h=8.5%)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.13, w * 0.30, h * 0.085),
        const Radius.circular(3),
      ),
      crossPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.radius != radius;
}
