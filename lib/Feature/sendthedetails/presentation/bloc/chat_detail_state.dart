import 'package:equatable/equatable.dart';
import '../../domain/entities/message_item.dart';

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object?> get props => [];
}

class ChatDetailInitial extends ChatDetailState {
  const ChatDetailInitial();
}

class ChatDetailLoading extends ChatDetailState {
  const ChatDetailLoading();
}

class ChatDetailLoaded extends ChatDetailState {
  final List<MessageItem> messages;

  const ChatDetailLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatDetailError extends ChatDetailState {
  final String message;

  const ChatDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
