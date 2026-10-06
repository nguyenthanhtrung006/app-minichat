import '../../domain/entities/call_session.dart';
import '../../domain/repositories/calling_repository.dart';
import '../datasources/calling_remote_datasource.dart';

class CallingRepositoryImpl implements CallingRepository {
  final CallingRemoteDataSource remoteDataSource;

  const CallingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CallSession> acceptCall(CallSession session) async =>
      await remoteDataSource.acceptCall(session);

  @override
  Future<CallSession> declineCall(CallSession session) async =>
      await remoteDataSource.declineCall(session);

  @override
  Future<CallSession> endCall(CallSession session) async =>
      await remoteDataSource.endCall(session);

  @override
  Future<CallSession> toggleMute(CallSession session) async =>
      await remoteDataSource.toggleMute(session);

  @override
  Future<CallSession> toggleSpeaker(CallSession session) async =>
      await remoteDataSource.toggleSpeaker(session);

  @override
  Future<CallSession> toggleVideo(CallSession session) async =>
      await remoteDataSource.toggleVideo(session);

  @override
  Future<CallSession> switchCamera(CallSession session) async =>
      await remoteDataSource.switchCamera(session);
}
