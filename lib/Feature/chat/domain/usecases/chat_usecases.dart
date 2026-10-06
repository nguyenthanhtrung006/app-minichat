import '../entities/chat_item.dart';
import '../repositories/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository repository;

  const GetChatsUseCase({required this.repository});

  Future<List<ChatItem>> call() async {
    return await repository.getChats();
  }
}

class SearchChatsUseCase {
  final ChatRepository repository;

  const SearchChatsUseCase({required this.repository});

  Future<List<ChatItem>> call(String query) async {
    return await repository.searchChats(query);
  }
}
