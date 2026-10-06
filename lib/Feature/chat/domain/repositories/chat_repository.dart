import '../entities/chat_item.dart';

abstract class ChatRepository {
  Future<List<ChatItem>> getChats();
  Future<List<ChatItem>> searchChats(String query);
}
