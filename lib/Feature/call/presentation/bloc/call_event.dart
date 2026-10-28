import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class CallStarted extends CallEvent {
  const CallStarted();
}

class CallRefreshed extends CallEvent {
  const CallRefreshed();
}

class CallLoadMore extends CallEvent {
  const CallLoadMore();
}
