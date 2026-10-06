import 'package:flutter/material.dart';

/// Renders the dot indicators at the bottom of the landing screen.
class LandingDotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final ValueChanged<int>? onDotTapped;

  const LandingDotsIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;

        return GestureDetector(
          onTap: () => onDotTapped?.call(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4.5),
            width: isActive ? 10.0 : 8.0,
            height: isActive ? 10.0 : 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF007DFE)
                  : const Color(0xFFCFE4FF),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF007DFE).withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
