import 'package:flutter/material.dart';

/// Top header for Landing Page 2 ("Tất cả trong một")
/// Renders 4 floating 3D squircle cards:
/// 1. Chat (Blue gradient + speech bubble + red badge)
/// 2. Call (Mint green gradient + phone handset)
/// 3. Mail (Sky blue gradient + envelope)
/// 4. Group (Purple-blue gradient + group members)
/// Along with soft ambient 3D spheres and a center sparkle.
class FeaturesGridHeader extends StatefulWidget {
  final double height;

  const FeaturesGridHeader({
    super.key,
    required this.height,
  });

  @override
  State<FeaturesGridHeader> createState() => _FeaturesGridHeaderState();
}

class _FeaturesGridHeaderState extends State<FeaturesGridHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnim1;
  late final Animation<double> _floatAnim2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnim1 = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _floatAnim2 = Tween<double>(begin: 4.0, end: -4.0).animate(
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
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Sky blue gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3EA1FD),
                    Color(0xFF72C2FE),
                    Color(0xFFC7E8FE),
                    Colors.white,
                  ],
                  stops: [0.0, 0.40, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // 2. Soft ambient 3D cloud spheres in background
          Positioned(
            top: widget.height * 0.15,
            right: screenWidth * 0.08,
            child: _buildAmbientSphere(90),
          ),
          Positioned(
            top: widget.height * 0.32,
            right: screenWidth * 0.02,
            child: _buildAmbientSphere(130),
          ),
          Positioned(
            top: widget.height * 0.22,
            left: screenWidth * 0.05,
            child: _buildAmbientSphere(110),
          ),

          // 3. Floating 4 Cards Layout
          SizedBox(
            width: 280,
            height: 250,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Center Star Sparkle
                    Positioned(
                      left: 132,
                      top: 110,
                      child: CustomPaint(
                        size: const Size(22, 22),
                        painter: _StarSparklePainter(),
                      ),
                    ),

                    // Card 1: Top-Left (Chat)
                    Positioned(
                      left: 20,
                      top: 12 + _floatAnim1.value,
                      child: _buildFeatureCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF53A5FF), Color(0xFF1B70EF)],
                        ),
                        shadowColor: const Color(0xFF1B70EF),
                        child: _buildChatBubbleIcon(),
                      ),
                    ),

                    // Card 2: Top-Right (Phone Call)
                    Positioned(
                      right: 25,
                      top: 38 + _floatAnim2.value,
                      child: _buildFeatureCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF34D4A1), Color(0xFF14B27C)],
                        ),
                        shadowColor: const Color(0xFF14B27C),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),

                    // Card 3: Middle-Left (Mail / Messages)
                    Positioned(
                      left: 12,
                      top: 120 + _floatAnim2.value,
                      child: _buildFeatureCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF37B4FF), Color(0xFF0985ED)],
                        ),
                        shadowColor: const Color(0xFF0985ED),
                        child: const Icon(
                          Icons.mail_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),

                    // Card 4: Bottom-Right (Group)
                    Positioned(
                      right: 18,
                      top: 145 + _floatAnim1.value,
                      child: _buildFeatureCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF677BFE), Color(0xFF4358E9)],
                        ),
                        shadowColor: const Color(0xFF4358E9),
                        child: const Icon(
                          Icons.group_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 4. Subtle bottom white fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required Gradient gradient,
    required Color shadowColor,
    required Widget child,
    double size = 74.0,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: gradient,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.32),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildChatBubbleIcon() {
    return SizedBox(
      width: 44,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // White speech bubble
          Positioned.fill(
            child: CustomPaint(
              painter: _SmallBubblePainter(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(),
                      const SizedBox(width: 2.5),
                      _buildDot(),
                      const SizedBox(width: 2.5),
                      _buildDot(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Red notification badge
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4863),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 5.5,
      height: 5.5,
      decoration: const BoxDecoration(
        color: Color(0xFF2683EB),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAmbientSphere(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
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
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h * 0.88),
      Radius.circular(w * 0.35),
    );

    final path = Path()
      ..addRRect(r)
      ..moveTo(w * 0.28, h * 0.84)
      ..quadraticBezierTo(w * 0.15, h * 0.94, w * 0.06, h * 0.98)
      ..quadraticBezierTo(w * 0.14, h * 0.88, w * 0.16, h * 0.78)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarSparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, h)
      ..quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
