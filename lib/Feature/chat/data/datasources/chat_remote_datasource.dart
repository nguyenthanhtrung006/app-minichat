import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_item.dart';
import '../../../../core/network/signalr_service.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatItem>> getChats();
  void addOrUpdateChat(ChatItem chat);
  void updateLastMessage({
    required String name,
    required String lastMessage,
    required String time,
    int unreadIncrement = 0,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  static final ChatRemoteDataSourceImpl _instance =
      ChatRemoteDataSourceImpl._internal();
  static ChatRemoteDataSourceImpl get instance => _instance;

  final List<ChatItem> _chats = [];

  factory ChatRemoteDataSourceImpl() {
    return _instance;
  }

  ChatRemoteDataSourceImpl._internal() {
    // Lắng nghe tin nhắn mới từ SignalR để cập nhật cuộc trò chuyện lên đầu danh sách
    SignalRService.instance.messageStream.listen((data) {
      if (data == null) return;
      try {
        if (data is Map) {
          final senderId = data['senderId']?.toString();
          final myId = SignalRService.instance.currentUserId;
          if (senderId != null && myId != null && senderId == myId) {
            return;
          }
          final senderName = data['senderName']?.toString() ?? 'Người dùng';
          final text = data['content']?.toString() ??
              data['text']?.toString() ??
              data['message']?.toString() ??
              '';
          final now = DateTime.now();
          final timeStr =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          updateLastMessage(
            name: senderName,
            lastMessage: text,
            time: timeStr,
            unreadIncrement: 1,
          );
        }
      } catch (e) {
        debugPrint('⚠️ [ChatRemoteDataSource] Lỗi cập nhật tin nhắn SignalR: $e');
      }
    });

    // Lắng nghe trạng thái online/offline của người dùng
    SignalRService.instance.onlineStatusStream.listen((data) {
      if (data is Map) {
        final isOnline = data['isOnline'] as bool? ?? false;
        final userId = data['userId']?.toString();
        for (var i = 0; i < _chats.length; i++) {
          if (_chats[i].id == userId) {
            _chats[i] = ChatItem(
              id: _chats[i].id,
              name: _chats[i].name,
              lastMessage: _chats[i].lastMessage,
              time: _chats[i].time,
              unreadCount: _chats[i].unreadCount,
              isOnline: isOnline,
              avatarUrl: _chats[i].avatarUrl,
              isGroup: _chats[i].isGroup,
            );
          }
        }
      }
    });
  }

  @override
  void addOrUpdateChat(ChatItem chat) {
    final idx = _chats.indexWhere((c) => c.name == chat.name || c.id == chat.id);
    if (idx != -1) {
      _chats[idx] = chat;
    } else {
      _chats.insert(0, chat);
    }
  }

  @override
  void updateLastMessage({
    required String name,
    required String lastMessage,
    required String time,
    int unreadIncrement = 0,
  }) {
    final idx = _chats.indexWhere((c) => c.name == name);
    if (idx != -1) {
      final existing = _chats[idx];
      _chats.removeAt(idx);
      _chats.insert(
        0,
        ChatItem(
          id: existing.id,
          name: existing.name,
          lastMessage: lastMessage,
          time: time,
          unreadCount: existing.unreadCount + unreadIncrement,
          isOnline: existing.isOnline,
          avatarUrl: existing.avatarUrl,
          isGroup: existing.isGroup,
        ),
      );
    } else {
      _chats.insert(
        0,
        ChatItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          lastMessage: lastMessage,
          time: time,
          unreadCount: unreadIncrement,
          isOnline: true,
        ),
      );
    }
  }

  @override
  Future<List<ChatItem>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List<ChatItem>.from(_chats);
  }
}
