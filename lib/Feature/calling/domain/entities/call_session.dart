enum CallType { audio, video }

enum CallStatus { incoming, outgoing, active, declined, ended, noAnswer }

class CallSession {
  final String callerName;
  final String? callerAvatarUrl;
  final CallType callType;
  final CallStatus callStatus;
  final int durationSeconds;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoEnabled;
  final bool isFrontCamera;
  final bool isWeakNetwork;

  const CallSession({
    required this.callerName,
    this.callerAvatarUrl,
    this.callType = CallType.audio,
    this.callStatus = CallStatus.incoming,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isVideoEnabled = true,
    this.isFrontCamera = true,
    this.isWeakNetwork = false,
  });

  String get durationFormatted {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  CallSession copyWith({
    String? callerName,
    String? callerAvatarUrl,
    CallType? callType,
    CallStatus? callStatus,
    int? durationSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isVideoEnabled,
    bool? isFrontCamera,
    bool? isWeakNetwork,
  }) {
    return CallSession(
      callerName: callerName ?? this.callerName,
      callerAvatarUrl: callerAvatarUrl ?? this.callerAvatarUrl,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isWeakNetwork: isWeakNetwork ?? this.isWeakNetwork,
    );
  }
}
