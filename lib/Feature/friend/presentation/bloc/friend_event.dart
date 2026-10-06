import 'package:equatable/equatable.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}

class FriendStarted extends FriendEvent {
  const FriendStarted();
}

class FriendSearchChanged extends FriendEvent {
  final String query;

  const FriendSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FriendRequestToggled extends FriendEvent {
  final String requestId;

  const FriendRequestToggled(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
