import 'package:equatable/equatable.dart';

abstract class CallingEvent extends Equatable {
  const CallingEvent();

  @override
  List<Object?> get props => [];
}

class CallingInitRequested extends CallingEvent {
  const CallingInitRequested();
}

class CallAcceptPressed extends CallingEvent {
  const CallAcceptPressed();
}

class CallDeclinePressed extends CallingEvent {
  const CallDeclinePressed();
}

class CallEndPressed extends CallingEvent {
  const CallEndPressed();
}

class CallTimerTick extends CallingEvent {
  const CallTimerTick();
}

class CallMuteTogglePressed extends CallingEvent {
  const CallMuteTogglePressed();
}

class CallSpeakerTogglePressed extends CallingEvent {
  const CallSpeakerTogglePressed();
}

class CallVideoTogglePressed extends CallingEvent {
  const CallVideoTogglePressed();
}

class CallCameraSwitchPressed extends CallingEvent {
  const CallCameraSwitchPressed();
}

/// Khi cuộc gọi không có người nhấc máy (cuộc gọi nhỡ) -> phát [khongnghemay.mp3]
class CallNoAnswerPressed extends CallingEvent {
  const CallNoAnswerPressed();
}

/// Khi trạng thái mạng yếu bật/tắt trong cuộc gọi -> phát [mangyeu.mp3]
class CallWeakNetworkToggled extends CallingEvent {
  const CallWeakNetworkToggled();
}

/// Các sự kiện Realtime nhận được từ CallHub Server:
class CallRingingReceived extends CallingEvent {
  const CallRingingReceived();
}

class CallAcceptedReceived extends CallingEvent {
  final String? callSessionId;
  const CallAcceptedReceived({this.callSessionId});

  @override
  List<Object?> get props => [callSessionId];
}

class CallRejectedReceived extends CallingEvent {
  final String reason;
  const CallRejectedReceived({this.reason = 'Cuộc gọi bị từ chối'});

  @override
  List<Object?> get props => [reason];
}

class CallEndedReceived extends CallingEvent {
  final int? durationInSeconds;
  const CallEndedReceived({this.durationInSeconds});

  @override
  List<Object?> get props => [durationInSeconds];
}

class CallUserBusyReceived extends CallingEvent {
  final String message;
  const CallUserBusyReceived({this.message = 'Đối phương đang bận'});

  @override
  List<Object?> get props => [message];
}

class CallUserOfflineReceived extends CallingEvent {
  final String message;
  const CallUserOfflineReceived({this.message = 'Đối phương hiện không trực tuyến'});

  @override
  List<Object?> get props => [message];
}
