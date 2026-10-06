import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/entities/call_session.dart';
import 'call_control_button.dart';

/// Screen: "Nhận cuộc gọi" (Incoming Call).
/// Đang phát nhạc chuông cuộc gọi đến [nhacchuongden.mp3]
class IncomingCallView extends StatefulWidget {
  final CallSession session;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onNoAnswer;

  const IncomingCallView({
    super.key,
    required this.session,
    required this.onAccept,
    required this.onDecline,
    this.onNoAnswer,
  });

  @override
  State<IncomingCallView> createState() => _IncomingCallViewState();
}

class _IncomingCallViewState extends State<IncomingCallView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 60),

        // Caller Info Section
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007DFE).withValues(alpha: 0.25),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: AppAvatar(
                  name: widget.session.callerName,
                  size: 104,
                  imageUrl: widget.session.callerAvatarUrl,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.session.callerName,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.session.callType == CallType.video
                  ? lang.videoCallIncoming
                  : lang.incomingCall,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),
            // Badge nhạc chuông cuộc gọi đến
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF4ADE80),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Đang đổ chuông (nhacchuongden)...',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Bottom Actions: Decline (Red) and Accept (Green)
        Padding(
          padding: const EdgeInsets.only(bottom: 54, left: 32, right: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onNoAnswer != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ActionChip(
                    avatar: const Icon(Icons.phone_missed, size: 14, color: Colors.amberAccent),
                    label: Text(
                      'Thử nghiệm: Không nghe máy',
                      style: GoogleFonts.nunito(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.4)),
                    onPressed: widget.onNoAnswer,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline Button (phát amthanhkhongtraloidienthoai.mp3)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CallControlButton(
                        icon: Icons.call_end_rounded,
                        size: 64,
                        iconSize: 32,
                        backgroundColor: const Color(0xFFEF4444),
                        iconColor: Colors.white,
                        onTap: widget.onDecline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Từ chối',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  // Accept Button (ngừng chuông, bắt đầu cuộc gọi)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CallControlButton(
                        icon: widget.session.callType == CallType.video
                            ? Icons.videocam_rounded
                            : Icons.call_rounded,
                        size: 64,
                        iconSize: 32,
                        backgroundColor: const Color(0xFF22C55E),
                        iconColor: Colors.white,
                        onTap: widget.onAccept,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nghe máy',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
