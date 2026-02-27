import 'dart:math';
import 'package:flutter/material.dart';

class GlassDonutChart extends StatelessWidget {
  const GlassDonutChart({super.key, required this.totalValue});

  final String totalValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Conic gradients for segments
          CustomPaint(size: const Size(220, 220), painter: _DonutPainter()),
          // Center glass panel
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff1e1e2d).withValues(alpha: 0.6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff94a3b8),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalValue,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 35.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Pink Segment (29%)
    paint.color = const Color(0xffec4899);
    canvas.drawArc(rect, -pi / 2, pi * 2 * 0.29, false, paint);

    // Purple Segment (21%)
    paint.color = const Color(0xffa855f7);
    canvas.drawArc(
      rect,
      -pi / 2 + (pi * 2 * 0.30),
      pi * 2 * 0.21,
      false,
      paint,
    );

    // Blue Segment (30%)
    paint.color = const Color(0xff3b82f6);
    canvas.drawArc(
      rect,
      -pi / 2 + (pi * 2 * 0.52),
      pi * 2 * 0.30,
      false,
      paint,
    );

    // Teal Segment (20%)
    paint.color = const Color(0xff14b8a6);
    canvas.drawArc(
      rect,
      -pi / 2 + (pi * 2 * 0.83),
      pi * 2 * 0.17,
      false,
      paint,
    );

    // Add glow with another pass if needed, for now colors are enough
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
