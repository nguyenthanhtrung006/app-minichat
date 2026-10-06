import '../../domain/entities/call_session.dart';

abstract class CallingRemoteDataSource {
  Future<CallSession> acceptCall(CallSession session);
  Future<CallSession> declineCall(CallSession session);
  Future<CallSession> endCall(CallSession session);
  Future<CallSession> toggleMute(CallSession session);
  Future<CallSession> toggleSpeaker(CallSession session);
  Future<CallSession> toggleVideo(CallSession session);
  Future<CallSession> switchCamera(CallSession session);
}

class CallingRemoteDataSourceImpl implements CallingRemoteDataSource {
  @override
  Future<CallSession> acceptCall(CallSession session) async {
    return session.copyWith(
      callStatus: CallStatus.active,
      durationSeconds: 0,
    );
  }

  @override
  Future<CallSession> declineCall(CallSession session) async {
    return session.copyWith(
      callStatus: CallStatus.declined,
    );
  }

  @override
  Future<CallSession> endCall(CallSession session) async {
    return session.copyWith(
      callStatus: CallStatus.ended,
    );
  }

  @override
  Future<CallSession> toggleMute(CallSession session) async {
    return session.copyWith(isMuted: !session.isMuted);
  }

  @override
  Future<CallSession> toggleSpeaker(CallSession session) async {
    return session.copyWith(isSpeakerOn: !session.isSpeakerOn);
  }

  @override
  Future<CallSession> toggleVideo(CallSession session) async {
    return session.copyWith(isVideoEnabled: !session.isVideoEnabled);
  }

  @override
  Future<CallSession> switchCamera(CallSession session) async {
    return session.copyWith(isFrontCamera: !session.isFrontCamera);
  }
}
