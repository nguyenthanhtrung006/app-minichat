import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../data/services/call_signaling_service.dart';
import '../../domain/entities/call_session.dart';
import 'call_control_button.dart';

/// Screen: "Gọi thoại mới" / "Gọi video" (Outgoing Call).
/// Hỗ trợ Live Camera Preview toàn màn hình khi gọi Video WebRTC.
/// Đang phát nhạc chờ [nhacchuongdi.mp3]
class OutgoingCallView extends StatefulWidget {
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
  State<OutgoingCallView> createState() => _OutgoingCallViewState();
}

class _OutgoingCallViewState extends State<OutgoingCallView> {
  @override
  void initState() {
    super.initState();
    CallSignalingService.instance.onLocalStreamUpdated = (_) {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    CallSignalingService.instance.onLocalStreamUpdated = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.session.callType == CallType.video;
    final signaling = CallSignalingService.instance;
    final hasLocalVideo = signaling.localRenderer.srcObject != null;

    if (isVideo && widget.session.isVideoEnabled && hasLocalVideo) {
      return _buildVideoOutgoingView(context);
    }
    return _buildVoiceOrFallbackOutgoingView(context);
  }

  /// Giao diện Video Call Outgoing: Hiển thị Live Camera người gọi toàn màn hình
  Widget _buildVideoOutgoingView(BuildContext context) {
    final lang = context.l10n;
    final signaling = CallSignalingService.instance;

    return Stack(
      children: [
        // 1. Live Camera Preview nền toàn màn hình
        Positioned.fill(
          child: RTCVideoView(
            signaling.localRenderer,
            mirror: widget.session.isFrontCamera,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),

        // 2. Lớp phủ Gradient mờ tối ưu hiển thị chữ và các nút điều khiển
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // 3. Thông tin người nhận và trạng thái đang đổ chuông
        Positioned(
          top: 70,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007DFE).withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: AppAvatar(
                  name: widget.session.callerName,
                  size: 88,
                  imageUrl: widget.session.callerAvatarUrl,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.session.callerName,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lang.videoCallOutgoing,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF007DFE).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_rounded,
                      color: Color(0xFF60A5FA),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Đang đổ chuông...',
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. Các nút điều khiển phía dưới
        Positioned(
          bottom: 48,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CallControlButton(
                icon: Icons.flip_camera_ios_rounded,
                size: 54,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                iconColor: Colors.white,
                onTap: widget.onSwitchCamera ?? () {},
              ),
              const SizedBox(width: 24),
              CallControlButton(
                icon: widget.session.isVideoEnabled
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                size: 54,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                iconColor: Colors.white,
                onTap: widget.onToggleVideo ?? () {},
              ),
              const SizedBox(width: 24),
              CallControlButton(
                icon: Icons.call_end_rounded,
                size: 64,
                iconSize: 32,
                backgroundColor: const Color(0xFFEF4444),
                iconColor: Colors.white,
                onTap: widget.onCancel,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Giao diện Thoại hoặc Video khi Camera chưa sẵn sàng / tắt cam
  Widget _buildVoiceOrFallbackOutgoingView(BuildContext context) {
    final lang = context.l10n;
    final isVideo = widget.session.callType == CallType.video;

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
                name: widget.session.callerName,
                size: 104,
                imageUrl: widget.session.callerAvatarUrl,
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
              isVideo ? lang.videoCallOutgoing : lang.outgoingCall,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),
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
                  Icon(
                    isVideo ? Icons.videocam_rounded : Icons.music_note_rounded,
                    color: const Color(0xFF60A5FA),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Đang đổ chuông...',
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

        // Standard Bottom Actions
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0, left: 16, right: 16),
          child: isVideo
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CallControlButton(
                      icon: Icons.flip_camera_ios_rounded,
                      size: 54,
                      backgroundColor: const Color(0xFF007DFE),
                      iconColor: Colors.white,
                      onTap: widget.onSwitchCamera ?? () {},
                    ),
                    const SizedBox(width: 24),
                    CallControlButton(
                      icon: widget.session.isVideoEnabled
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      size: 54,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      iconColor: Colors.white,
                      onTap: widget.onToggleVideo ?? () {},
                    ),
                    const SizedBox(width: 24),
                    CallControlButton(
                      icon: Icons.call_end_rounded,
                      size: 60,
                      iconSize: 30,
                      backgroundColor: const Color(0xFFEF4444),
                      iconColor: Colors.white,
                      onTap: widget.onCancel,
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
                      onTap: widget.onCancel,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
