import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/entities/call_session.dart';
import 'call_control_button.dart';

/// Screen: "Cuộc gọi đang diễn ra" (Active Call).
/// Hỗ trợ bật/tắt Mic, Loa, Video, và mô phỏng / cảnh báo Mạng yếu [mangyeu.mp3]
class ActiveCallView extends StatelessWidget {
  final CallSession session;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleVideo;
  final VoidCallback onEndCall;
  final VoidCallback onToggleWeakNetwork;

  const ActiveCallView({
    super.key,
    required this.session,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onToggleVideo,
    required this.onEndCall,
    required this.onToggleWeakNetwork,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top section with Caller Info & Network Warning
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 50),

            // Banner cảnh báo mạng yếu nếu isWeakNetwork == true
            if (session.isWeakNetwork)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                      color: Color(0xFFF87171),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang.weakNetworkWarning,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFCA5A5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up, size: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),

            AppAvatar(
              name: session.callerName,
              size: 80,
              imageUrl: session.callerAvatarUrl,
            ),
            const SizedBox(height: 18),
            Text(
              session.callerName,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              session.durationFormatted,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Nút mô phỏng / kiểm tra âm thanh Mạng yếu (mangyeu.mp3)
            ActionChip(
              avatar: Icon(
                session.isWeakNetwork
                    ? Icons.signal_cellular_connected_no_internet_4_bar_rounded
                    : Icons.network_cell_rounded,
                size: 14,
                color: session.isWeakNetwork ? Colors.redAccent : Colors.lightGreenAccent,
              ),
              label: Text(
                session.isWeakNetwork ? 'Đang mạng yếu (mangyeu)' : 'Thử nghiệm: Mạng yếu',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: session.isWeakNetwork
                  ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.12),
              side: BorderSide(
                color: session.isWeakNetwork
                    ? Colors.redAccent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.25),
              ),
              onPressed: onToggleWeakNetwork,
            ),
          ],
        ),

        // Bottom In-Call Controls Row & End Call Button
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 54),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Controls Row (Mic, Loa, Video)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CallControlButton(
                    icon: session.isMuted
                        ? Icons.mic_off_rounded
                        : Icons.mic_rounded,
                    label: lang.mic,
                    size: 58,
                    isActive: session.isMuted,
                    onTap: onToggleMute,
                  ),
                  CallControlButton(
                    icon: session.isSpeakerOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded,
                    label: lang.speaker,
                    size: 58,
                    isActive: session.isSpeakerOn,
                    onTap: onToggleSpeaker,
                  ),
                  CallControlButton(
                    icon: session.isVideoEnabled
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    label: lang.video,
                    size: 58,
                    isActive: !session.isVideoEnabled,
                    onTap: onToggleVideo,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Red Hang Up Button
              CallControlButton(
                icon: Icons.call_end_rounded,
                size: 64,
                iconSize: 32,
                backgroundColor: const Color(0xFFEF4444),
                iconColor: Colors.white,
                onTap: onEndCall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
