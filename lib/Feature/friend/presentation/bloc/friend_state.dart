import 'package:equatable/equatable.dart';
import '../../domain/entities/friend_entities.dart';

abstract class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {
  const FriendInitial();
}

class FriendLoading extends FriendState {
  const FriendLoading();
}

class FriendLoaded extends FriendState {
  final List<FriendRequest> requests;
  final List<FriendItem> allFriends;
  final List<FriendItem> filteredFriends;
  final String searchQuery;

  const FriendLoaded({
    required this.requests,
    required this.allFriends,
    required this.filteredFriends,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props =>
      [requests, allFriends, filteredFriends, searchQuery];
}

class FriendError extends FriendState {
  final String message;

  const FriendError(this.message);

  @override
  List<Object?> get props => [message];
}
