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
    on<ChatRefreshed>(_onChatRefreshed);
    on<ChatLoadMore>(_onChatLoadMore);
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

  Future<void> _onChatRefreshed(
    ChatRefreshed event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final chats = await getChatsUseCase();
      final query = state is ChatLoaded ? (state as ChatLoaded).searchQuery : '';
      if (query.isNotEmpty) {
        final filtered = await searchChatsUseCase(query);
        emit(ChatLoaded(
          allChats: chats,
          filteredChats: filtered,
          searchQuery: query,
        ));
      } else {
        emit(ChatLoaded(allChats: chats, filteredChats: chats));
      }
    } catch (_) {}
  }

  Future<void> _onChatLoadMore(
    ChatLoadMore event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      // Giả lập load thêm cuộc trò chuyện (hoặc từ database)
      await Future.delayed(const Duration(milliseconds: 300));
      emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
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
