import '../entities/message_item.dart';

abstract class ChatDetailRepository {
  Future<List<MessageItem>> getMessages(String contactName);
  Future<MessageItem> sendMessage({
    required String contactName,
    required String text,
  });
}
