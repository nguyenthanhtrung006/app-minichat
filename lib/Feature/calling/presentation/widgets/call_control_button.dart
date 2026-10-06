import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable circular button for in-call controls (Mic, Loa, Video, Camera switch, Call End, Call Accept).
class CallControlButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final bool isActive;

  const CallControlButton({
    super.key,
    required this.icon,
    this.label,
    required this.onTap,
    this.backgroundColor = const Color(0x33FFFFFF), // Transparent white
    this.iconColor = Colors.white,
    this.size = 56,
    this.iconSize = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = isActive ? Colors.white : backgroundColor;
    final effectiveIconColor = isActive ? const Color(0xFF0F172A) : iconColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: effectiveBg,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: GoogleFonts.nunito(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );
  }
}
