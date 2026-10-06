import '../entities/call_session.dart';

abstract class CallingRepository {
  Future<CallSession> acceptCall(CallSession session);
  Future<CallSession> declineCall(CallSession session);
  Future<CallSession> endCall(CallSession session);
  Future<CallSession> toggleMute(CallSession session);
  Future<CallSession> toggleSpeaker(CallSession session);
  Future<CallSession> toggleVideo(CallSession session);
  Future<CallSession> switchCamera(CallSession session);
}
