import 'package:equatable/equatable.dart';
import '../../domain/entities/message_item.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailStarted extends ChatDetailEvent {
  final String contactName;
  final int? conversationId;
  final String? targetUserId;

  const ChatDetailStarted(
    this.contactName, {
    this.conversationId,
    this.targetUserId,
  });

  @override
  List<Object?> get props => [contactName, conversationId, targetUserId];
}

class ChatDetailMessageSent extends ChatDetailEvent {
  final String contactName;
  final String text;
  final int? conversationId;
  final String? targetUserId;

  const ChatDetailMessageSent({
    required this.contactName,
    required this.text,
    this.conversationId,
    this.targetUserId,
  });

  @override
  List<Object?> get props => [contactName, text, conversationId, targetUserId];
}

class ChatDetailMessageReceived extends ChatDetailEvent {
  final MessageItem message;

  const ChatDetailMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatDetailTypingChanged extends ChatDetailEvent {
  final bool isTyping;

  const ChatDetailTypingChanged(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}
