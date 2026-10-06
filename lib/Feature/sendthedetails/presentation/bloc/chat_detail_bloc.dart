import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/chat_detail_usecases.dart';
import 'chat_detail_event.dart';
import 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatDetailBloc({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(const ChatDetailInitial()) {
    on<ChatDetailStarted>(_onChatDetailStarted);
    on<ChatDetailMessageSent>(_onChatDetailMessageSent);
  }

  Future<void> _onChatDetailStarted(
    ChatDetailStarted event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(const ChatDetailLoading());
    try {
      final messages = await getMessagesUseCase(event.contactName);
      emit(ChatDetailLoaded(messages));
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> _onChatDetailMessageSent(
    ChatDetailMessageSent event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      await sendMessageUseCase(
        contactName: event.contactName,
        text: event.text,
      );
      final updated = await getMessagesUseCase(event.contactName);
      emit(ChatDetailLoaded(updated));
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }
}
