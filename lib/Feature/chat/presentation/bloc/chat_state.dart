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

  const ChatLoaded({
    required this.allChats,
    required this.filteredChats,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allChats, filteredChats, searchQuery];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
