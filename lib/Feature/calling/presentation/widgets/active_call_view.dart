import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../data/services/call_signaling_service.dart';
import '../../domain/entities/call_session.dart';
import 'call_control_button.dart';

/// Screen: "Cuộc gọi đang diễn ra" (Active Call).
/// Hỗ trợ cuộc gọi thoại (Voice) & video WebRTC P2P thời gian thực:
/// - Video Call: Render Remote Video toàn màn hình + Local Preview PiP góc trên
/// - Voice Call: Avatar + Trạng thái đàm thoại
/// - Điều khiển Microphone, Loa ngoài, Bật/Tắt Camera, Đổi Camera trước/sau
/// - Cảnh báo mạng yếu [mangyeu.mp3]
class ActiveCallView extends StatefulWidget {
  final CallSession session;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleVideo;
  final VoidCallback onEndCall;
  final VoidCallback onToggleWeakNetwork;
  final VoidCallback? onSwitchCamera;

  const ActiveCallView({
    super.key,
    required this.session,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onToggleVideo,
    required this.onEndCall,
    required this.onToggleWeakNetwork,
    this.onSwitchCamera,
  });

  @override
  State<ActiveCallView> createState() => _ActiveCallViewState();
}

class _ActiveCallViewState extends State<ActiveCallView> {
  @override
  void initState() {
    super.initState();
    CallSignalingService.instance.onRemoteStreamUpdated = (_) {
      if (mounted) setState(() {});
    };
    CallSignalingService.instance.onLocalStreamUpdated = (_) {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    CallSignalingService.instance.onRemoteStreamUpdated = null;
    CallSignalingService.instance.onLocalStreamUpdated = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.callType == CallType.video) {
      return _buildVideoCallView(context);
    }
    return _buildVoiceCallView(context);
  }

  /// Giao diện cuộc gọi Video WebRTC
  Widget _buildVideoCallView(BuildContext context) {
    final lang = context.l10n;
    final signaling = CallSignalingService.instance;
    final hasRemoteVideo = signaling.remoteRenderer.srcObject != null;
    final hasLocalVideo = signaling.localRenderer.srcObject != null;

    return Stack(
      children: [
        // 1. Remote Video Background (Toàn màn hình)
        Positioned.fill(
          child: hasRemoteVideo
              ? RTCVideoView(
                  signaling.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAvatar(
                          name: widget.session.callerName,
                          size: 96,
                          imageUrl: widget.session.callerAvatarUrl,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.session.callerName,
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF007DFE),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đang kết nối luồng video...',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // 2. PiP Local Camera Preview (Góc trên bên phải)
        Positioned(
          top: 20,
          right: 20,
          width: 110,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.session.isVideoEnabled && hasLocalVideo
                  ? RTCVideoView(
                      signaling.localRenderer,
                      mirror: widget.session.isFrontCamera,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam_off_rounded,
                            color: Colors.white70,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tắt cam',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),

        // 3. Top Header Bar (Tên, thời lượng, cảnh báo mạng yếu, đổi camera)
        Positioned(
          top: 16,
          left: 16,
          right: 140, // Tránh đè lên PiP local view
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.session.callerName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.session.durationFormatted,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ],
                ),
              ),

              // Cảnh báo mạng yếu nếu bật
              if (widget.session.isWeakNetwork) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lang.weakNetworkWarning,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 4. Bottom Controls Overlay
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút đổi Camera trước/sau & chip mạng yếu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.onSwitchCamera != null)
                      IconButton(
                        onPressed: widget.onSwitchCamera,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flip_camera_ios_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ActionChip(
                      avatar: Icon(
                        widget.session.isWeakNetwork
                            ? Icons.signal_cellular_connected_no_internet_4_bar_rounded
                            : Icons.network_cell_rounded,
                        size: 14,
                        color: widget.session.isWeakNetwork
                            ? Colors.redAccent
                            : Colors.lightGreenAccent,
                      ),
                      label: Text(
                        widget.session.isWeakNetwork
                            ? 'Mạng yếu (mangyeu)'
                            : 'Thử mạng yếu',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      onPressed: widget.onToggleWeakNetwork,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Dãy nút điều khiển chính
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallControlButton(
                      icon: widget.session.isMuted
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      label: lang.mic,
                      size: 52,
                      isActive: widget.session.isMuted,
                      onTap: widget.onToggleMute,
                    ),
                    CallControlButton(
                      icon: widget.session.isSpeakerOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_rounded,
                      label: lang.speaker,
                      size: 52,
                      isActive: widget.session.isSpeakerOn,
                      onTap: widget.onToggleSpeaker,
                    ),
                    CallControlButton(
                      icon: widget.session.isVideoEnabled
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      label: lang.video,
                      size: 52,
                      isActive: !widget.session.isVideoEnabled,
                      onTap: widget.onToggleVideo,
                    ),
                    CallControlButton(
                      icon: Icons.call_end_rounded,
                      size: 56,
                      iconSize: 28,
                      backgroundColor: const Color(0xFFEF4444),
                      iconColor: Colors.white,
                      onTap: widget.onEndCall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Giao diện cuộc gọi thoại (Voice Call)
  Widget _buildVoiceCallView(BuildContext context) {
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
            if (widget.session.isWeakNetwork)
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
              name: widget.session.callerName,
              size: 80,
              imageUrl: widget.session.callerAvatarUrl,
            ),
            const SizedBox(height: 18),
            Text(
              widget.session.callerName,
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
              widget.session.durationFormatted,
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
                widget.session.isWeakNetwork
                    ? Icons.signal_cellular_connected_no_internet_4_bar_rounded
                    : Icons.network_cell_rounded,
                size: 14,
                color: widget.session.isWeakNetwork
                    ? Colors.redAccent
                    : Colors.lightGreenAccent,
              ),
              label: Text(
                widget.session.isWeakNetwork
                    ? 'Đang mạng yếu (mangyeu)'
                    : 'Thử nghiệm: Mạng yếu',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: widget.session.isWeakNetwork
                  ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.12),
              side: BorderSide(
                color: widget.session.isWeakNetwork
                    ? Colors.redAccent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.25),
              ),
              onPressed: widget.onToggleWeakNetwork,
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
                    icon: widget.session.isMuted
                        ? Icons.mic_off_rounded
                        : Icons.mic_rounded,
                    label: lang.mic,
                    size: 58,
                    isActive: widget.session.isMuted,
                    onTap: widget.onToggleMute,
                  ),
                  CallControlButton(
                    icon: widget.session.isSpeakerOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded,
                    label: lang.speaker,
                    size: 58,
                    isActive: widget.session.isSpeakerOn,
                    onTap: widget.onToggleSpeaker,
                  ),
                  CallControlButton(
                    icon: widget.session.isVideoEnabled
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    label: lang.video,
                    size: 58,
                    isActive: !widget.session.isVideoEnabled,
                    onTap: widget.onToggleVideo,
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
                onTap: widget.onEndCall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
