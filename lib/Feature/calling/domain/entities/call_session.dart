enum CallType { audio, video }

enum CallStatus { incoming, outgoing, active, declined, ended, noAnswer }

class CallSession {
  final String callerName;
  final String? callerAvatarUrl;
  final String? callSessionId;
  final int? targetUserId;
  final CallType callType;
  final CallStatus callStatus;
  final int durationSeconds;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoEnabled;
  final bool isFrontCamera;
  final bool isWeakNetwork;
  final String? statusMessage;

  const CallSession({
    required this.callerName,
    this.callerAvatarUrl,
    this.callSessionId,
    this.targetUserId,
    this.callType = CallType.audio,
    this.callStatus = CallStatus.incoming,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isVideoEnabled = true,
    this.isFrontCamera = true,
    this.isWeakNetwork = false,
    this.statusMessage,
  });

  String get durationFormatted {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  CallSession copyWith({
    String? callerName,
    String? callerAvatarUrl,
    String? callSessionId,
    int? targetUserId,
    CallType? callType,
    CallStatus? callStatus,
    int? durationSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isVideoEnabled,
    bool? isFrontCamera,
    bool? isWeakNetwork,
    String? statusMessage,
  }) {
    return CallSession(
      callerName: callerName ?? this.callerName,
      callerAvatarUrl: callerAvatarUrl ?? this.callerAvatarUrl,
      callSessionId: callSessionId ?? this.callSessionId,
      targetUserId: targetUserId ?? this.targetUserId,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isWeakNetwork: isWeakNetwork ?? this.isWeakNetwork,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
