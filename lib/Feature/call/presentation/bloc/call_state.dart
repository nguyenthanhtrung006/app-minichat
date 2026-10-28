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
  final bool hasReachedMax;
  final bool isLoadingMore;

  const CallLoaded(
    this.calls, {
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CallLoaded copyWith({
    List<CallItem>? calls,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CallLoaded(
      calls ?? this.calls,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [calls, hasReachedMax, isLoadingMore];
}

class CallError extends CallState {
  final String message;

  const CallError(this.message);

  @override
  List<Object?> get props => [message];
}
