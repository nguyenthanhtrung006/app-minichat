import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders the origami paper airplane with 3D folded facets
/// and a dashed flight trail curve.
class SplashPaperPlane extends StatefulWidget {
  final double size;

  const SplashPaperPlane({
    super.key,
    this.size = 76.0,
  });

  @override
  State<SplashPaperPlane> createState() => _SplashPaperPlaneState();
}

class _SplashPaperPlaneState extends State<SplashPaperPlane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_hoverAnimation.value * 0.5, _hoverAnimation.value),
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size * 2.2,
        height: widget.size * 1.5,
        child: Stack(
          children: [
            // Flight trail (dashed arc behind airplane)
            Positioned.fill(
              child: CustomPaint(
                painter: _FlightTrailPainter(),
              ),
            ),

            // Paper airplane
            Positioned(
              right: 0,
              top: widget.size * 0.1,
              child: Transform.rotate(
                angle: -math.pi * 0.08,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size * 0.85,
                  child: CustomPaint(
                    painter: _PaperAirplanePainter(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws an origami paper airplane with geometric shading
class _PaperAirplanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Nose tip of airplane
    final nose = Offset(w * 0.95, h * 0.08);

    // Left / main wing facet (light/medium blue)
    final mainWingPaint = Paint()
      ..color = const Color(0xFF4C9FFD)
      ..style = PaintingStyle.fill;

    final mainWingPath = Path()
      ..moveTo(nose.dx, nose.dy)
      ..lineTo(w * 0.18, h * 0.70)
      ..lineTo(w * 0.52, h * 0.56)
      ..close();
    canvas.drawPath(mainWingPath, mainWingPaint);

    // Underbelly center fold (lighter highlight)
    final centerFlapPaint = Paint()
      ..color = const Color(0xFF75B8FF)
      ..style = PaintingStyle.fill;

    final centerFlapPath = Path()
      ..moveTo(nose.dx, nose.dy)
      ..lineTo(w * 0.52, h * 0.56)
      ..lineTo(w * 0.38, h * 0.86)
      ..close();
    canvas.drawPath(centerFlapPath, centerFlapPaint);

    // Right / lower shaded wing facet (deep royal blue)
    final rightWingPaint = Paint()
      ..color = const Color(0xFF1D6EE5)
      ..style = PaintingStyle.fill;

    final rightWingPath = Path()
      ..moveTo(nose.dx, nose.dy)
      ..lineTo(w * 0.38, h * 0.86)
      ..lineTo(w * 0.78, h * 0.92)
      ..close();
    canvas.drawPath(rightWingPath, rightWingPaint);

    // Airplane subtle drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF0F479C).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(rightWingPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws a dashed flight trail curve
class _FlightTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.05, h * 0.90);
    path.quadraticBezierTo(w * 0.38, h * 0.78, w * 0.62, h * 0.42);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, path, paint, dashLength: 6, gapLength: 5);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length) {
        final end = math.min(start + dashLength, metric.length);
        final extract = metric.extractPath(start, end);
        canvas.drawPath(extract, paint);
        start += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
