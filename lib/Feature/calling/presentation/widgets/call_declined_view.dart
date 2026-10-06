import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Screen: "Từ chối cuộc gọi / Không trả lời điện thoại" (Call Declined).
/// Phát âm thanh [amthanhkhongtraloidienthoai.mp3]
class CallDeclinedView extends StatefulWidget {
  final VoidCallback onDismiss;

  const CallDeclinedView({
    super.key,
    required this.onDismiss,
  });

  @override
  State<CallDeclinedView> createState() => _CallDeclinedViewState();
}

class _CallDeclinedViewState extends State<CallDeclinedView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Chờ âm thanh amthanhkhongtraloidienthoai.mp3 phát xong hoặc người dùng nhấn đóng
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

    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              lang.callDeclined,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang.youDeclinedCall,
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
                    Icons.volume_up_rounded,
                    color: Color(0xFFF87171),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang phát âm thanh thông báo...',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
