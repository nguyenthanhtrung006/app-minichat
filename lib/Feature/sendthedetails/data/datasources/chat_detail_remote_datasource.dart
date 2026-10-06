import '../../domain/entities/message_item.dart';
import '../mock_message_data.dart';

abstract class ChatDetailRemoteDataSource {
  Future<List<MessageItem>> getMessages(String contactName);
  Future<MessageItem> sendMessage({
    required String contactName,
    required String text,
  });
}

class ChatDetailRemoteDataSourceImpl implements ChatDetailRemoteDataSource {
  final Map<String, List<MessageItem>> _cachedMessages = {};

  @override
  Future<List<MessageItem>> getMessages(String contactName) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_cachedMessages.containsKey(contactName)) {
      _cachedMessages[contactName] =
          MockMessageData.getInitialMessages(contactName);
    }
    return List<MessageItem>.from(_cachedMessages[contactName]!);
  }

  @override
  Future<MessageItem> sendMessage({
    required String contactName,
    required String text,
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
      _cachedMessages[contactName] =
          MockMessageData.getInitialMessages(contactName);
    }
    _cachedMessages[contactName]!.add(msg);
    return msg;
  }
}
