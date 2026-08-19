import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScoreArc extends StatefulWidget {
  final int score;
  final String grade;

  const ScoreArc({Key? key, required this.score, required this.grade})
      : super(key: key);

  @override
  State<ScoreArc> createState() => _ScoreArcState();
}

class _ScoreArcState extends State<ScoreArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ScoreArc old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static Color _gradeColor(String grade) {
    switch (grade) {
      case 'high':   return const Color(0xFF10b981);
      case 'medium': return const Color(0xFF3b82f6);
      case 'low':    return const Color(0xFFf59e0b);
      default:       return const Color(0xFF8b5cf6);
    }
  }

  static String _gradeLabel(String grade) {
    switch (grade) {
      case 'high':   return 'Active Member';
      case 'medium': return 'Growing';
      case 'low':    return 'Developing';
      default:       return 'Getting Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(widget.grade);
    final label = _gradeLabel(widget.grade);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final animatedScore = (widget.score * _anim.value).round();
        return SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _ArcPainter(
              progress: _anim.value * widget.score / 100,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '$animatedScore',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748b),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your engagement this season',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94a3b8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;

  // Arc: 240° sweep, 120° gap centred at bottom
  // startAngle = 150° from 3-o'clock (clockwise) ≈ 2.618 rad
  static const double _startRad = 150 * math.pi / 180;
  static const double _sweepRad = 240 * math.pi / 180;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 14;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    const strokeWidth = 14.0;

    // Background track
    canvas.drawArc(
      rect,
      _startRad,
      _sweepRad,
      false,
      Paint()
        ..color = const Color(0xFFe2e8f0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Foreground arc
    canvas.drawArc(
      rect,
      _startRad,
      _sweepRad * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
