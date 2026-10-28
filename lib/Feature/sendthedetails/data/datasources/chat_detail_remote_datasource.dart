import 'package:flutter/foundation.dart';
import '../../domain/entities/message_item.dart';
import '../../../../core/network/signalr_service.dart';

abstract class ChatDetailRemoteDataSource {
  Future<List<MessageItem>> getMessages(String contactName);
  Future<MessageItem> sendMessage({
    required String contactName,
    required String text,
    int? conversationId,
    String? targetUserId,
  });
  void addIncomingMessage(String contactName, MessageItem message);
}

class ChatDetailRemoteDataSourceImpl implements ChatDetailRemoteDataSource {
  static final ChatDetailRemoteDataSourceImpl _instance =
      ChatDetailRemoteDataSourceImpl._internal();
  static ChatDetailRemoteDataSourceImpl get instance => _instance;

  final Map<String, List<MessageItem>> _cachedMessages = {};

  factory ChatDetailRemoteDataSourceImpl() {
    return _instance;
  }

  ChatDetailRemoteDataSourceImpl._internal() {
    // Lắng nghe tin nhắn realtime từ SignalR để cập nhật vào bộ nhớ đệm
    SignalRService.instance.messageStream.listen((data) {
      if (data == null) return;
      try {
        if (data is Map) {
          final senderId = data['senderId']?.toString();
          final myId = SignalRService.instance.currentUserId;
          // Bỏ qua tin nhắn do chính mình gửi đi (đã có trong bộ nhớ đệm rồi)
          if (senderId != null && myId != null && senderId == myId) {
            return;
          }
        }
        final incoming = MessageItem.fromSignalR(data, isMe: false);
        final contactName = incoming.senderName;
        addIncomingMessage(contactName, incoming);
      } catch (e) {
        debugPrint('⚠️ [ChatDetailRemoteDataSource] Lỗi xử lý tin nhắn SignalR: $e');
      }
    });
  }

  @override
  void addIncomingMessage(String contactName, MessageItem message) {
    if (!_cachedMessages.containsKey(contactName)) {
      _cachedMessages[contactName] = [];
    }
    final isDuplicate = _cachedMessages[contactName]!.any((m) =>
        m.id == message.id ||
        (m.text == message.text &&
            m.isMe == message.isMe &&
            m.senderName == message.senderName &&
            m.time == message.time));
    if (isDuplicate) return;

    _cachedMessages[contactName]!.add(message);
  }

  @override
  Future<List<MessageItem>> getMessages(String contactName) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_cachedMessages.containsKey(contactName)) {
      // Bắt đầu cuộc trò chuyện với danh sách tin nhắn trống, không dùng dữ liệu cứng
      _cachedMessages[contactName] = [];
    }
    return List<MessageItem>.from(_cachedMessages[contactName]!);
  }

  @override
  Future<MessageItem> sendMessage({
    required String contactName,
    required String text,
    int? conversationId,
    String? targetUserId,
  }) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final msg = MessageItem(
      id: now.millisecondsSinceEpoch.toString(),
      text: text,
      time: timeStr,
      isMe: true,
      senderName: 'Tôi',
    );

    if (!_cachedMessages.containsKey(contactName)) {
      _cachedMessages[contactName] = [];
    }
    _cachedMessages[contactName]!.add(msg);

    // Gửi tin nhắn qua SignalR Realtime đến backend
    final convId = conversationId ??
        ((contactName.hashCode & 0x7FFFFFFF) % 100000 + 1);
    final receiverId = int.tryParse(targetUserId ?? '');
    try {
      await SignalRService.instance.sendMessage(
        conversationId: convId,
        content: text,
        receiverName: contactName,
        receiverId: receiverId,
      );
    } catch (e) {
      debugPrint('⚠️ [ChatDetailRemoteDataSource] Chưa thể gửi qua SignalR ($e)');
    }

    return msg;
  }
}
