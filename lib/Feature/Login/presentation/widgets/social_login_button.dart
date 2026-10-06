import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SocialType { google, facebook }

/// Pill button for third-party social logins (Google, Facebook).
class SocialLoginButton extends StatelessWidget {
  final SocialType type;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(26),
          splashColor: Colors.grey.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon() {
    if (type == SocialType.google) {
      return CustomPaint(
        size: const Size(20, 20),
        painter: _GoogleLogoPainter(),
      );
    } else {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFF1877F2),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'f',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
      );
    }
  }
}

/// Draws official Google 'G' multicolored logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final redPaint = Paint()..color = const Color(0xFFEA4335);

    // Blue bar & top right
    final bluePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.25)
      ..lineTo(w, center.dy - radius * 0.25)
      ..lineTo(w, center.dy + radius * 0.25)
      ..lineTo(center.dx, center.dy + radius * 0.25)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.45;

    // Red arc (top)
    strokePaint.color = redPaint.color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      3.14 * 1.15,
      3.14 * 0.70,
      false,
      strokePaint,
    );

    // Yellow arc (left)
    strokePaint.color = yellowPaint.color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      3.14 * 0.65,
      3.14 * 0.50,
      false,
      strokePaint,
    );

    // Green arc (bottom)
    strokePaint.color = greenPaint.color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      3.14 * 0.15,
      3.14 * 0.50,
      false,
      strokePaint,
    );

    // Blue arc (right lower)
    strokePaint.color = bluePaint.color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      0,
      3.14 * 0.25,
      false,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
