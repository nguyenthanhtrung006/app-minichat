import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUseCase getChatsUseCase;
  final SearchChatsUseCase searchChatsUseCase;

  ChatBloc({
    required this.getChatsUseCase,
    required this.searchChatsUseCase,
  }) : super(const ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatSearchChanged>(_onChatSearchChanged);
  }

  Future<void> _onChatStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final chats = await getChatsUseCase();
      emit(ChatLoaded(allChats: chats, filteredChats: chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onChatSearchChanged(
    ChatSearchChanged event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final filtered = await searchChatsUseCase(event.query);
      emit(
        ChatLoaded(
          allChats: currentState.allChats,
          filteredChats: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }
}
