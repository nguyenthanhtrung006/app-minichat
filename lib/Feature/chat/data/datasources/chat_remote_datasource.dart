import '../../domain/entities/chat_item.dart';
import '../mock_chat_data.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatItem>> getChats();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<List<ChatItem>> getChats() async {
    // Simulated remote network call
    await Future.delayed(const Duration(milliseconds: 150));
    return List<ChatItem>.from(MockChatData.mockChats);
  }
}
