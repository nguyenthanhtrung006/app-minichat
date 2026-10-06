import 'package:flutter/material.dart';

/// Interactive Viewfinder with laser animation, glowing corner brackets,
/// and camera sensor backdrop simulation.
class QrViewfinderWidget extends StatefulWidget {
  final double scanBoxSize;
  final bool isFlashOn;

  const QrViewfinderWidget({
    super.key,
    this.scanBoxSize = 250,
    this.isFlashOn = false,
  });

  @override
  State<QrViewfinderWidget> createState() => _QrViewfinderWidgetState();
}

class _QrViewfinderWidgetState extends State<QrViewfinderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.06, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _laserAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _ViewfinderPainter(
            scanBoxSize: widget.scanBoxSize,
            laserPercent: _laserAnimation.value,
            isFlashOn: widget.isFlashOn,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final double scanBoxSize;
  final double laserPercent;
  final bool isFlashOn;

  _ViewfinderPainter({
    required this.scanBoxSize,
    required this.laserPercent,
    required this.isFlashOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    // Center cutout area
    final double actualBox = (size.width * 0.68).clamp(200.0, 260.0);
    final double left = (size.width - actualBox) / 2;
    // Position slightly above vertical center to give room for bottom controls
    final double top = (size.height - actualBox) / 2 - 35;
    final double right = left + actualBox;
    final double bottom = top + actualBox;

    final scanRect = Rect.fromLTRB(left, top, right, bottom);
    final fullRect = Offset.zero & size;

    // 1. Dark semi-transparent mask outside cutout box
    final bgPaint = Paint()
      ..color = const Color(0xB3050811);

    final bgPath = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(22)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(bgPath, bgPaint);

    // 3. Subtle inner border line
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(22)),
      borderPaint,
    );

    // 4. Vibrant Neon Blue Corner Brackets
    final cornerPaint = Paint()
      ..color = const Color(0xFF007DFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    const cornerRadius = 18.0;

    // Top-Left Corner
    final tlPath = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, top),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right Corner
    final trPath = Path()
      ..moveTo(right - cornerLength, top)
      ..lineTo(right - cornerRadius, top)
      ..arcToPoint(
        Offset(right, top + cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(right, top + cornerLength);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left Corner
    final blPath = Path()
      ..moveTo(left, bottom - cornerLength)
      ..lineTo(left, bottom - cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, bottom),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right Corner
    final brPath = Path()
      ..moveTo(right - cornerLength, bottom)
      ..lineTo(right - cornerRadius, bottom)
      ..arcToPoint(
        Offset(right, bottom - cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(right, bottom - cornerLength);
    canvas.drawPath(brPath, cornerPaint);

    // 5. Glowing Laser Scanning Line
    final laserY = top + (actualBox * laserPercent);

    // Halo gradient behind laser line
    final haloPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x38007DFE),
          const Color(0x00007DFE),
        ],
      ).createShader(Rect.fromLTRB(left + 10, laserY - 18, right - 10, laserY))
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(left + 10, laserY - 18, right - 10, laserY),
      haloPaint,
    );

    // Laser bar
    final laserPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x00007DFE),
          Color(0xFF38BDF8),
          Color(0xFFFFFFFF),
          Color(0xFF38BDF8),
          Color(0x00007DFE),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTRB(left + 6, laserY, right - 6, laserY + 3))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(left + 10, laserY),
      Offset(right - 10, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) {
    return oldDelegate.laserPercent != laserPercent ||
        oldDelegate.isFlashOn != isFlashOn ||
        oldDelegate.scanBoxSize != scanBoxSize;
  }
}
