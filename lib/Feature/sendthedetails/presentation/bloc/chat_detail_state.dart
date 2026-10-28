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
  final bool isContactTyping;

  const ChatDetailLoaded(this.messages, {this.isContactTyping = false});

  @override
  List<Object?> get props => [messages, isContactTyping];

  ChatDetailLoaded copyWith({
    List<MessageItem>? messages,
    bool? isContactTyping,
  }) {
    return ChatDetailLoaded(
      messages ?? this.messages,
      isContactTyping: isContactTyping ?? this.isContactTyping,
    );
  }
}

class ChatDetailError extends ChatDetailState {
  final String message;

  const ChatDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
