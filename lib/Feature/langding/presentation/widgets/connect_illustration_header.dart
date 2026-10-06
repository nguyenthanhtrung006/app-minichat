import 'package:flutter/material.dart';

/// Top header for Landing Page 1 (Connect Screen)
/// Displays the couple chatting on phones with floating paper planes and clouds.
class ConnectIllustrationHeader extends StatelessWidget {
  final double height;

  const ConnectIllustrationHeader({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Sky blue gradient background behind illustration
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF389BF9),
                    Color(0xFF67BCFD),
                    Color(0xFFBCE1FE),
                    Colors.white,
                  ],
                  stops: [0.0, 0.40, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // 2. High fidelity Illustration of the boy & girl chatting - tràn viền trên
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_connect.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                // Fallback elegant vector placeholder if asset isn't loaded yet
                return const _FallbackConnectIllustration();
              },
            ),
          ),

          // 3. Subtle bottom soft white cloud curve blending with body
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.75),
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
}

class _FallbackConnectIllustration extends StatelessWidget {
  const _FallbackConnectIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.forum_rounded,
        size: 100,
        color: const Color(0xFF007DFE).withValues(alpha: 0.6),
      ),
    );
  }
}
