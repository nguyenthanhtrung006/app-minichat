import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders the capsule progress bar and loading text indicator
/// driven by BLoC progress values.
class SplashProgressBar extends StatelessWidget {
  final double progress;
  final String statusText;
  final double width;
  final double height;

  const SplashProgressBar({
    super.key,
    required this.progress,
    this.statusText = 'Đang tải...',
    this.width = 175.0,
    this.height = 7.5,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp progress between 0.0 and 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Capsule Progress Bar
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1660C8).withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(height),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Stack(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: clampedProgress),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(height),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Loading status text
        Text(
          statusText,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: const Color(0xFF0F4F9B).withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
