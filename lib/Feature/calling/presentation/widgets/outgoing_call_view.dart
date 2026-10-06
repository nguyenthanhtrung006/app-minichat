import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/entities/call_session.dart';
import 'call_control_button.dart';

/// Screen: "Gọi thoại mới" / "Gọi video" (Outgoing Call).
/// Đang phát nhạc chờ [nhacchuongdi.mp3]
class OutgoingCallView extends StatelessWidget {
  final CallSession session;
  final VoidCallback onCancel;
  final VoidCallback? onSwitchCamera;
  final VoidCallback? onToggleVideo;
  final VoidCallback? onAccept;
  final VoidCallback? onNoAnswer;
  final VoidCallback? onDecline;

  const OutgoingCallView({
    super.key,
    required this.session,
    required this.onCancel,
    this.onSwitchCamera,
    this.onToggleVideo,
    this.onAccept,
    this.onNoAnswer,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;
    final isVideo = session.callType == CallType.video;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 60),

        // Caller Info Section
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                name: session.callerName,
                size: 104,
                imageUrl: session.callerAvatarUrl,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              session.callerName,
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
              isVideo ? lang.videoCallOutgoing : lang.outgoingCall,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),
            // Badge biểu thị đang đổ chuông / phát nhạc chờ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF007DFE).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    color: Color(0xFF60A5FA),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Đang đổ chuông (nhacchuongdi)...',
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

        // Quick simulation testing toolbar & Call Controls
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simulation quick chips for testing sounds
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (onAccept != null)
                    ActionChip(
                      avatar: const Icon(Icons.call, size: 14, color: Colors.greenAccent),
                      label: Text(
                        'Nhấc máy',
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      side: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.4)),
                      onPressed: onAccept,
                    ),
                  if (onNoAnswer != null)
                    ActionChip(
                      avatar: const Icon(Icons.phone_missed, size: 14, color: Colors.amberAccent),
                      label: Text(
                        'Không nghe máy',
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.4)),
                      onPressed: onNoAnswer,
                    ),
                  if (onDecline != null)
                    ActionChip(
                      avatar: const Icon(Icons.call_end, size: 14, color: Colors.redAccent),
                      label: Text(
                        'Không trả lời',
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                      onPressed: onDecline,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Standard Bottom Actions
              isVideo
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CallControlButton(
                          icon: Icons.flip_camera_ios_rounded,
                          size: 54,
                          backgroundColor: const Color(0xFF007DFE),
                          iconColor: Colors.white,
                          onTap: onSwitchCamera ?? () {},
                        ),
                        const SizedBox(width: 24),
                        CallControlButton(
                          icon: session.isVideoEnabled
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          size: 54,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          iconColor: Colors.white,
                          onTap: onToggleVideo ?? () {},
                        ),
                        const SizedBox(width: 24),
                        CallControlButton(
                          icon: Icons.call_end_rounded,
                          size: 60,
                          iconSize: 30,
                          backgroundColor: const Color(0xFFEF4444),
                          iconColor: Colors.white,
                          onTap: onCancel,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CallControlButton(
                          icon: Icons.call_end_rounded,
                          size: 64,
                          iconSize: 32,
                          backgroundColor: const Color(0xFFEF4444),
                          iconColor: Colors.white,
                          onTap: onCancel,
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
