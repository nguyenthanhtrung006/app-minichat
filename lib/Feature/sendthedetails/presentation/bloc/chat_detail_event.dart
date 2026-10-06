import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailStarted extends ChatDetailEvent {
  final String contactName;

  const ChatDetailStarted(this.contactName);

  @override
  List<Object?> get props => [contactName];
}

class ChatDetailMessageSent extends ChatDetailEvent {
  final String contactName;
  final String text;

  const ChatDetailMessageSent({
    required this.contactName,
    required this.text,
  });

  @override
  List<Object?> get props => [contactName, text];
}
