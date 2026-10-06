import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Screen: "Không nghe máy" (No Answer / Missed Call).
/// Phát âm thanh [khongnghemay.mp3]
class CallNoAnswerView extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onRetry;

  const CallNoAnswerView({
    super.key,
    required this.onDismiss,
    this.onRetry,
  });

  @override
  State<CallNoAnswerView> createState() => _CallNoAnswerViewState();
}

class _CallNoAnswerViewState extends State<CallNoAnswerView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Chờ âm thanh khongnghemay.mp3 phát xong hoặc người dùng nhấn đóng
    _timer = Timer(const Duration(milliseconds: 5500), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.phone_missed_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lang.noAnswer,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang.recipientNoAnswer,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.ring_volume_rounded,
                  color: Color(0xFFFBBF24),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Âm thanh không nghe máy...',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onDismiss,
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                label: Text(
                  'Đóng',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
