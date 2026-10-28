import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/call_audio_service.dart';
import '../../data/services/call_signaling_service.dart';
import '../../domain/entities/call_session.dart';
import '../../domain/usecases/calling_usecases.dart';
import 'calling_event.dart';
import 'calling_state.dart';

class CallingBloc extends Bloc<CallingEvent, CallingState> {
  final AcceptCallUseCase acceptCallUseCase;
  final DeclineCallUseCase declineCallUseCase;
  final EndCallUseCase endCallUseCase;
  final ToggleMuteUseCase toggleMuteUseCase;
  final ToggleSpeakerUseCase toggleSpeakerUseCase;
  final ToggleVideoUseCase toggleVideoUseCase;
  final SwitchCameraUseCase switchCameraUseCase;
  final CallAudioService audioService;
  final CallSignalingService signalingService;

  Timer? _ticker;

  CallingBloc({
    required CallSession initialSession,
    required this.acceptCallUseCase,
    required this.declineCallUseCase,
    required this.endCallUseCase,
    required this.toggleMuteUseCase,
    required this.toggleSpeakerUseCase,
    required this.toggleVideoUseCase,
    required this.switchCameraUseCase,
    CallAudioService? audioService,
    CallSignalingService? signalingService,
  })  : audioService = audioService ?? CallAudioServiceImpl(),
        signalingService = signalingService ?? CallSignalingService.instance,
        super(CallingState(session: initialSession)) {
    on<CallingInitRequested>(_onInit);
    on<CallAcceptPressed>(_onAccept);
    on<CallDeclinePressed>(_onDecline);
    on<CallEndPressed>(_onEnd);
    on<CallTimerTick>(_onTick);
    on<CallMuteTogglePressed>(_onToggleMute);
    on<CallSpeakerTogglePressed>(_onToggleSpeaker);
    on<CallVideoTogglePressed>(_onToggleVideo);
    on<CallCameraSwitchPressed>(_onSwitchCamera);
    on<CallNoAnswerPressed>(_onNoAnswer);
    on<CallWeakNetworkToggled>(_onToggleWeakNetwork);

    // Xử lý các sự kiện Realtime từ CallHub
    on<CallRingingReceived>(_onRinging);
    on<CallAcceptedReceived>(_onCallAccepted);
    on<CallRejectedReceived>(_onCallRejected);
    on<CallEndedReceived>(_onCallEnded);
    on<CallUserBusyReceived>(_onUserBusy);
    on<CallUserOfflineReceived>(_onUserOffline);

    _attachSignalingListeners();
    _handleInitialAudio(initialSession);
  }

  void _attachSignalingListeners() {
    signalingService.onCallRinging = (_) => add(const CallRingingReceived());
    signalingService.onCallAccepted = (data) => add(
          CallAcceptedReceived(
            callSessionId: data['callSessionId']?.toString(),
          ),
        );
    signalingService.onCallRejected = (reason) => add(
          CallRejectedReceived(reason: reason),
        );
    signalingService.onCallEnded = (data) => add(
          CallEndedReceived(
            durationInSeconds: data['durationInSeconds'] is int
                ? data['durationInSeconds'] as int
                : int.tryParse(data['durationInSeconds']?.toString() ?? '0'),
          ),
        );
    signalingService.onUserBusy = (msg) => add(CallUserBusyReceived(message: msg));
    signalingService.onUserOffline = (msg) => add(CallUserOfflineReceived(message: msg));
  }

  void _handleInitialAudio(CallSession session) {
    if (session.callStatus == CallStatus.incoming) {
      // Cuộc gọi đến: phát nhạc chuông nhacchuongden.mp3
      audioService.playIncoming();
    } else if (session.callStatus == CallStatus.outgoing) {
      // Cuộc gọi đi: phát nhạc chờ nhacchuongdi.mp3
      audioService.playOutgoing();
      if (session.callType == CallType.video) {
        signalingService.initLocalStream(isVideo: true);
      }
      // Bắt đầu gọi lên Server nếu có targetUserId
      if (session.targetUserId != null) {
        signalingService.startCall(
          session.targetUserId!,
          callType: session.callType == CallType.video ? 'Video' : 'Voice',
        );
      }
    } else if (session.callStatus == CallStatus.active) {
      _startTimer();
    }
  }

  void _onInit(CallingInitRequested event, Emitter<CallingState> emit) {}

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const CallTimerTick());
    });
  }

  void _onRinging(CallRingingReceived event, Emitter<CallingState> emit) {
    audioService.playOutgoing();
  }

  Future<void> _onCallAccepted(
    CallAcceptedReceived event,
    Emitter<CallingState> emit,
  ) async {
    await audioService.stop();
    _startTimer();
    emit(
      CallingState(
        session: state.session.copyWith(
          callStatus: CallStatus.active,
          callSessionId: event.callSessionId ?? state.session.callSessionId,
        ),
      ),
    );
  }

  Future<void> _onCallRejected(
    CallRejectedReceived event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    await audioService.playDeclined();
    emit(
      CallingState(
        session: state.session.copyWith(
          callStatus: CallStatus.declined,
          statusMessage: event.reason,
        ),
      ),
    );
  }

  Future<void> _onCallEnded(
    CallEndedReceived event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    emit(
      CallingState(
        session: state.session.copyWith(
          callStatus: CallStatus.ended,
          durationSeconds: event.durationInSeconds ?? state.session.durationSeconds,
        ),
      ),
    );
  }

  Future<void> _onUserBusy(
    CallUserBusyReceived event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    await audioService.playDeclined();
    emit(
      CallingState(
        session: state.session.copyWith(
          callStatus: CallStatus.declined,
          statusMessage: event.message,
        ),
      ),
    );
  }

  Future<void> _onUserOffline(
    CallUserOfflineReceived event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    await audioService.playNoAnswer();
    emit(
      CallingState(
        session: state.session.copyWith(
          callStatus: CallStatus.noAnswer,
          statusMessage: event.message,
        ),
      ),
    );
  }

  Future<void> _onAccept(
    CallAcceptPressed event,
    Emitter<CallingState> emit,
  ) async {
    await audioService.stop();
    final sessionId = state.session.callSessionId ?? signalingService.currentCallSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      await signalingService.acceptCall(
        sessionId,
        isVideo: state.session.callType == CallType.video,
      );
    }
    final updated = await acceptCallUseCase(state.session);
    emit(CallingState(session: updated.copyWith(callSessionId: sessionId)));
    _startTimer();
  }

  Future<void> _onDecline(
    CallDeclinePressed event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    // Cuộc gọi từ chối / không trả lời: phát amthanhkhongtraloidienthoai.mp3
    await audioService.playDeclined();
    final sessionId = state.session.callSessionId ?? signalingService.currentCallSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      await signalingService.rejectCall(sessionId, reason: 'Bận');
    } else {
      signalingService.cleanUp();
    }
    final updated = await declineCallUseCase(state.session);
    emit(CallingState(session: updated));
  }

  Future<void> _onEnd(
    CallEndPressed event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    final sessionId = state.session.callSessionId ?? signalingService.currentCallSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      await signalingService.endCall(sessionId);
    } else {
      signalingService.cleanUp();
    }
    final updated = await endCallUseCase(state.session);
    emit(CallingState(session: updated));
  }

  Future<void> _onNoAnswer(
    CallNoAnswerPressed event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
    // Không nghe máy: phát khongnghemay.mp3
    await audioService.playNoAnswer();
    emit(CallingState(
      session: state.session.copyWith(callStatus: CallStatus.noAnswer),
    ));
  }

  Future<void> _onToggleWeakNetwork(
    CallWeakNetworkToggled event,
    Emitter<CallingState> emit,
  ) async {
    final nextWeak = !state.session.isWeakNetwork;
    if (nextWeak) {
      // Mạng yếu: phát mangyeu.mp3
      await audioService.playWeakNetwork();
    }
    emit(CallingState(
      session: state.session.copyWith(isWeakNetwork: nextWeak),
    ));
  }

  void _onTick(CallTimerTick event, Emitter<CallingState> emit) {
    if (state.session.callStatus == CallStatus.active) {
      final newSec = state.session.durationSeconds + 1;
      emit(
        CallingState(
          session: state.session.copyWith(durationSeconds: newSec),
        ),
      );
    }
  }

  Future<void> _onToggleMute(
    CallMuteTogglePressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await toggleMuteUseCase(state.session);
    signalingService.setMicrophoneMute(updated.isMuted);
    emit(CallingState(session: updated));
  }

  Future<void> _onToggleSpeaker(
    CallSpeakerTogglePressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await toggleSpeakerUseCase(state.session);
    await signalingService.setSpeakerphoneOn(updated.isSpeakerOn);
    emit(CallingState(session: updated));
  }

  Future<void> _onToggleVideo(
    CallVideoTogglePressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await toggleVideoUseCase(state.session);
    signalingService.setCameraEnabled(updated.isVideoEnabled);
    emit(CallingState(session: updated));
  }

  Future<void> _onSwitchCamera(
    CallCameraSwitchPressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await switchCameraUseCase(state.session);
    await signalingService.switchCamera();
    emit(CallingState(session: updated));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    audioService.stop();
    audioService.dispose();
    signalingService.cleanUp();
    return super.close();
  }
}
