import 'package:flutter/material.dart';

/// Renders the sky-blue gradient and atmospheric cloud silhouettes
/// matching the Mini Chat splash screen design.
class SplashBackground extends StatelessWidget {
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Sky blue gradient background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3897F8), // Top vibrant sky blue
                  Color(0xFF5AB6FD), // Upper mid blue
                  Color(0xFF86CBFE), // Mid light blue
                  Color(0xFFC7E8FE), // Cloud horizon tint
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // 2. Soft radial glow behind the main logo area
        Positioned(
          top: MediaQuery.of(context).size.height * 0.18,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 3. Layered Cloud formations at the bottom
        Positioned.fill(
          child: CustomPaint(
            painter: _CloudLayerPainter(),
          ),
        ),

        // 4. Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _CloudLayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- Layer 1: Distant soft translucent clouds (Upper cloud bank) ---
    final distantCloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, h * 0.70);
    path1.quadraticBezierTo(w * 0.15, h * 0.60, w * 0.35, h * 0.64);
    path1.quadraticBezierTo(w * 0.55, h * 0.58, w * 0.78, h * 0.63);
    path1.quadraticBezierTo(w * 0.92, h * 0.59, w, h * 0.64);
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();
    canvas.drawPath(path1, distantCloudPaint);

    // --- Layer 2: Mid-ground bright white billowy clouds ---
    final midCloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, h * 0.75);
    path2.quadraticBezierTo(w * 0.12, h * 0.67, w * 0.28, h * 0.70);
    path2.quadraticBezierTo(w * 0.48, h * 0.63, w * 0.68, h * 0.69);
    path2.quadraticBezierTo(w * 0.88, h * 0.66, w, h * 0.72);
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();
    canvas.drawPath(path2, midCloudPaint);

    // --- Layer 3: Soft ambient cyan cloud rim ---
    final softRimPaint = Paint()
      ..color = const Color(0xFFBCE3FE).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final pathRim = Path();
    pathRim.moveTo(0, h * 0.80);
    pathRim.quadraticBezierTo(w * 0.25, h * 0.74, w * 0.52, h * 0.78);
    pathRim.quadraticBezierTo(w * 0.75, h * 0.73, w, h * 0.79);
    pathRim.lineTo(w, h);
    pathRim.lineTo(0, h);
    pathRim.close();
    canvas.drawPath(pathRim, softRimPaint);

    // --- Layer 4: Foreground soft curved blue wave at bottom ---
    final foregroundBluePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2688F5),
          Color(0xFF156FE3),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.82, w, h * 0.18));

    final path3 = Path();
    path3.moveTo(0, h * 0.86);
    path3.quadraticBezierTo(w * 0.25, h * 0.82, w * 0.55, h * 0.87);
    path3.quadraticBezierTo(w * 0.80, h * 0.84, w, h * 0.88);
    path3.lineTo(w, h);
    path3.lineTo(0, h);
    path3.close();
    canvas.drawPath(path3, foregroundBluePaint);

    // Subtle darker bottom curve on the left
    final leftWavePaint = Paint()
      ..color = const Color(0xFF1166DA).withValues(alpha: 0.85);
    final path4 = Path();
    path4.moveTo(0, h * 0.88);
    path4.quadraticBezierTo(w * 0.22, h * 0.84, w * 0.42, h * 0.91);
    path4.lineTo(w * 0.42, h);
    path4.lineTo(0, h);
    path4.close();
    canvas.drawPath(path4, leftWavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
