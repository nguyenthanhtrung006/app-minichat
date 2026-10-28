import 'package:equatable/equatable.dart';
import '../../domain/entities/friend_entities.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}

class FriendStarted extends FriendEvent {
  const FriendStarted();
}

class FriendRefreshed extends FriendEvent {
  const FriendRefreshed();
}

class FriendLoadMore extends FriendEvent {
  const FriendLoadMore();
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

class FriendAdded extends FriendEvent {
  final FriendItem friend;

  const FriendAdded(this.friend);

  @override
  List<Object?> get props => [friend];
}

class FriendStreamUpdated extends FriendEvent {
  final List<FriendItem> friends;
  final List<FriendRequest> requests;

  const FriendStreamUpdated({
    required this.friends,
    required this.requests,
  });

  @override
  List<Object?> get props => [friends, requests];
}
