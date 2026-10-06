import 'package:equatable/equatable.dart';
import '../../domain/entities/call_item.dart';

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {
  const CallInitial();
}

class CallLoading extends CallState {
  const CallLoading();
}

class CallLoaded extends CallState {
  final List<CallItem> calls;

  const CallLoaded(this.calls);

  @override
  List<Object?> get props => [calls];
}

class CallError extends CallState {
  final String message;

  const CallError(this.message);

  @override
  List<Object?> get props => [message];
}
