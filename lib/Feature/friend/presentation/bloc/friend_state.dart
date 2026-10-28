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
  final bool hasReachedMax;
  final bool isLoadingMore;

  const FriendLoaded({
    required this.requests,
    required this.allFriends,
    required this.filteredFriends,
    this.searchQuery = '',
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  FriendLoaded copyWith({
    List<FriendRequest>? requests,
    List<FriendItem>? allFriends,
    List<FriendItem>? filteredFriends,
    String? searchQuery,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return FriendLoaded(
      requests: requests ?? this.requests,
      allFriends: allFriends ?? this.allFriends,
      filteredFriends: filteredFriends ?? this.filteredFriends,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        requests,
        allFriends,
        filteredFriends,
        searchQuery,
        hasReachedMax,
        isLoadingMore,
      ];
}

class FriendError extends FriendState {
  final String message;

  const FriendError(this.message);

  @override
  List<Object?> get props => [message];
}
