import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders the small floating chat bubble in the cloud area on the lower-left.
class SplashFloatingBubble extends StatefulWidget {
  final double size;

  const SplashFloatingBubble({
    super.key,
    this.size = 58.0,
  });

  @override
  State<SplashFloatingBubble> createState() => _SplashFloatingBubbleState();
}

class _SplashFloatingBubbleState extends State<SplashFloatingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 3.0, end: -3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Transform.rotate(
        angle: -math.pi * 0.05,
        child: Container(
          width: widget.size * 1.15,
          height: widget.size * 0.95,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF165DBB).withValues(alpha: 0.18),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _SmallBubblePainter(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: widget.size * 0.08),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(widget.size * 0.07),
                    SizedBox(width: widget.size * 0.035),
                    _buildDot(widget.size * 0.07),
                    SizedBox(width: widget.size * 0.035),
                    _buildDot(widget.size * 0.07),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(double dotSize) {
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: const BoxDecoration(
        color: Color(0xFF4598F7),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SmallBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;

    // Body
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h * 0.85),
      Radius.circular(w * 0.35),
    );

    final path = Path();
    path.addRRect(r);

    // Cute bubble tail
    path.moveTo(w * 0.28, h * 0.82);
    path.quadraticBezierTo(w * 0.16, h * 0.92, w * 0.08, h * 0.98);
    path.quadraticBezierTo(w * 0.15, h * 0.87, w * 0.18, h * 0.77);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
