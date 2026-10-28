import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message_item.dart';
import '../../domain/usecases/chat_detail_usecases.dart';
import '../../../../core/network/signalr_service.dart';
import 'chat_detail_event.dart';
import 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  String? _currentContactName;
  int? _conversationId;
  String? _targetUserId;

  ChatDetailBloc({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(const ChatDetailInitial()) {
    on<ChatDetailStarted>(_onChatDetailStarted);
    on<ChatDetailMessageSent>(_onChatDetailMessageSent);
    on<ChatDetailMessageReceived>(_onChatDetailMessageReceived);
    on<ChatDetailTypingChanged>(_onChatDetailTypingChanged);

    // Lắng nghe tin nhắn realtime từ SignalR
    _messageSubscription = SignalRService.instance.messageStream.listen((data) {
      if (data == null) return;
      try {
        if (data is Map) {
          final senderId = data['senderId']?.toString();
          final myId = SignalRService.instance.currentUserId;
          // Bỏ qua tin nhắn do chính mình gửi đi (đã vẽ bên phải rồi, tránh bị tự trả lời)
          if (senderId != null && myId != null && senderId == myId) {
            return;
          }
        }
        final item = MessageItem.fromSignalR(
          data,
          isMe: false,
          defaultSenderName: _currentContactName,
        );
        add(ChatDetailMessageReceived(item));
      } catch (_) {}
    });

    // Lắng nghe trạng thái người kia đang gõ phím
    _typingSubscription = SignalRService.instance.typingStream.listen((data) {
      if (data is Map) {
        final isTyping = data['isTyping'] as bool? ?? false;
        add(ChatDetailTypingChanged(isTyping));
      }
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    return super.close();
  }

  Future<void> _onChatDetailStarted(
    ChatDetailStarted event,
    Emitter<ChatDetailState> emit,
  ) async {
    _currentContactName = event.contactName;
    _conversationId = event.conversationId;
    _targetUserId = event.targetUserId;
    emit(const ChatDetailLoading());
    try {
      final messages = await getMessagesUseCase(event.contactName);
      emit(ChatDetailLoaded(messages, isContactTyping: false));
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> _onChatDetailMessageSent(
    ChatDetailMessageSent event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final sent = await sendMessageUseCase(
        contactName: event.contactName,
        text: event.text,
        conversationId: event.conversationId ?? _conversationId,
        targetUserId: event.targetUserId ?? _targetUserId,
      );
      if (state is ChatDetailLoaded) {
        final current = (state as ChatDetailLoaded).messages;
        emit((state as ChatDetailLoaded).copyWith(
          messages: [...current, sent],
        ));
      } else {
        emit(ChatDetailLoaded([sent], isContactTyping: false));
      }
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  void _onChatDetailMessageReceived(
    ChatDetailMessageReceived event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is ChatDetailLoaded) {
      final current = (state as ChatDetailLoaded).messages;
      // Khử trùng lặp: kiểm tra theo ID hoặc nội dung + người gửi + thời gian
      final isDuplicate = current.any((m) =>
          m.id == event.message.id ||
          (m.text == event.message.text &&
              m.isMe == event.message.isMe &&
              m.senderName == event.message.senderName &&
              m.time == event.message.time));
      if (isDuplicate) return;

      emit((state as ChatDetailLoaded).copyWith(
        messages: [...current, event.message],
      ));
    }
  }

  void _onChatDetailTypingChanged(
    ChatDetailTypingChanged event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is ChatDetailLoaded) {
      emit((state as ChatDetailLoaded).copyWith(
        isContactTyping: event.isTyping,
      ));
    }
  }
}
