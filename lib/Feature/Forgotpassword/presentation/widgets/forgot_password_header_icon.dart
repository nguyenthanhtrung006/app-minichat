import 'package:flutter/material.dart';

/// The hero icon container displaying a soft squircle with a blue mail envelope inside.
class ForgotPasswordHeaderIcon extends StatelessWidget {
  final double size;

  const ForgotPasswordHeaderIcon({
    super.key,
    this.size = 104.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F2FF),
        borderRadius: BorderRadius.circular(size * 0.30),
      ),
      child: Center(
        child: Container(
          width: size * 0.54,
          height: size * 0.40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF288BFE),
                Color(0xFF0A75F2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A75F2).withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _EnvelopeFlapPainter(),
          ),
        ),
      ),
    );
  }
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(4, 4)
      ..lineTo(w * 0.5, h * 0.60)
      ..lineTo(w - 4, 4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
