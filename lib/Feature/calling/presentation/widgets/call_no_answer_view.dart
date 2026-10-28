import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Screen: "Không nghe máy" (No Answer / Missed Call / User Offline).
/// Phát âm thanh [khongnghemay.mp3]
class CallNoAnswerView extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onRetry;
  final String? message;

  const CallNoAnswerView({
    super.key,
    required this.onDismiss,
    this.onRetry,
    this.message,
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
    final isOffline = widget.message != null &&
        (widget.message!.toLowerCase().contains('trực tuyến') ||
            widget.message!.toLowerCase().contains('offline'));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isOffline ? const Color(0xFF64748B) : const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isOffline ? const Color(0xFF64748B) : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.phone_missed_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isOffline ? 'Đối phương không trực tuyến' : lang.noAnswer,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              widget.message != null && widget.message!.isNotEmpty
                  ? '${widget.message}\n(Người nhận chưa mở ứng dụng trên thiết bị khác)'
                  : lang.recipientNoAnswer,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
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
                Icon(
                  isOffline ? Icons.info_outline_rounded : Icons.ring_volume_rounded,
                  color: isOffline ? const Color(0xFF94A3B8) : const Color(0xFFFBBF24),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isOffline ? 'Thông báo: Người nhận đang Offline' : 'Âm thanh không nghe máy...',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
