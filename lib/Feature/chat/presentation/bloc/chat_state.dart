import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_item.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatItem> allChats;
  final List<ChatItem> filteredChats;
  final String searchQuery;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const ChatLoaded({
    required this.allChats,
    required this.filteredChats,
    this.searchQuery = '',
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  ChatLoaded copyWith({
    List<ChatItem>? allChats,
    List<ChatItem>? filteredChats,
    String? searchQuery,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return ChatLoaded(
      allChats: allChats ?? this.allChats,
      filteredChats: filteredChats ?? this.filteredChats,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        allChats,
        filteredChats,
        searchQuery,
        hasReachedMax,
        isLoadingMore,
      ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
