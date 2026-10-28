import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatRefreshed extends ChatEvent {
  const ChatRefreshed();
}

class ChatLoadMore extends ChatEvent {
  const ChatLoadMore();
}

class ChatSearchChanged extends ChatEvent {
  final String query;

  const ChatSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
