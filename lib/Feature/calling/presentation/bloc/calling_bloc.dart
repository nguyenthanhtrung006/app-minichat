import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/call_audio_service.dart';
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
  })  : audioService = audioService ?? CallAudioServiceImpl(),
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

    _handleInitialAudio(initialSession);
  }

  void _handleInitialAudio(CallSession session) {
    if (session.callStatus == CallStatus.incoming) {
      // Cuộc gọi đến: phát nhạc chuông nhacchuongden.mp3
      audioService.playIncoming();
    } else if (session.callStatus == CallStatus.outgoing) {
      // Cuộc gọi đi: phát nhạc chờ nhacchuongdi.mp3
      audioService.playOutgoing();
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

  Future<void> _onAccept(
    CallAcceptPressed event,
    Emitter<CallingState> emit,
  ) async {
    await audioService.stop();
    final updated = await acceptCallUseCase(state.session);
    emit(CallingState(session: updated));
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
    final updated = await declineCallUseCase(state.session);
    emit(CallingState(session: updated));
  }

  Future<void> _onEnd(
    CallEndPressed event,
    Emitter<CallingState> emit,
  ) async {
    _ticker?.cancel();
    await audioService.stop();
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
    emit(CallingState(session: updated));
  }

  Future<void> _onToggleSpeaker(
    CallSpeakerTogglePressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await toggleSpeakerUseCase(state.session);
    emit(CallingState(session: updated));
  }

  Future<void> _onToggleVideo(
    CallVideoTogglePressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await toggleVideoUseCase(state.session);
    emit(CallingState(session: updated));
  }

  Future<void> _onSwitchCamera(
    CallCameraSwitchPressed event,
    Emitter<CallingState> emit,
  ) async {
    final updated = await switchCameraUseCase(state.session);
    emit(CallingState(session: updated));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    audioService.stop();
    audioService.dispose();
    return super.close();
  }
}
