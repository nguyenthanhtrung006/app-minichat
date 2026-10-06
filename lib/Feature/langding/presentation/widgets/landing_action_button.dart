import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The primary "Bắt đầu" call-to-action button with tap feedback & gradient glow.
class LandingActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const LandingActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 54.0,
  });

  @override
  State<LandingActionButton> createState() => _LandingActionButtonState();
}

class _LandingActionButtonState extends State<LandingActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF268DFF),
              Color(0xFF0774F5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F77F5).withValues(alpha: 0.38),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: BorderRadius.circular(widget.height / 2),
            splashColor: Colors.white.withValues(alpha: 0.25),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: Text(
                widget.text,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
