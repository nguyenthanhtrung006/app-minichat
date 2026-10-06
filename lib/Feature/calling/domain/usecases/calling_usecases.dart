import '../entities/call_session.dart';
import '../repositories/calling_repository.dart';

class AcceptCallUseCase {
  final CallingRepository repository;
  const AcceptCallUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.acceptCall(session);
}

class DeclineCallUseCase {
  final CallingRepository repository;
  const DeclineCallUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.declineCall(session);
}

class EndCallUseCase {
  final CallingRepository repository;
  const EndCallUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.endCall(session);
}

class ToggleMuteUseCase {
  final CallingRepository repository;
  const ToggleMuteUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.toggleMute(session);
}

class ToggleSpeakerUseCase {
  final CallingRepository repository;
  const ToggleSpeakerUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.toggleSpeaker(session);
}

class ToggleVideoUseCase {
  final CallingRepository repository;
  const ToggleVideoUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.toggleVideo(session);
}

class SwitchCameraUseCase {
  final CallingRepository repository;
  const SwitchCameraUseCase({required this.repository});
  Future<CallSession> call(CallSession session) async =>
      await repository.switchCamera(session);
}
