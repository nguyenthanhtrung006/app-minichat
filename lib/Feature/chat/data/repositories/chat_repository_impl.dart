import '../../domain/entities/chat_item.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  const ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatItem>> getChats() async {
    return await remoteDataSource.getChats();
  }

  @override
  Future<List<ChatItem>> searchChats(String query) async {
    final allChats = await remoteDataSource.getChats();
    if (query.trim().isEmpty) return allChats;
    return allChats
        .where(
          (c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.lastMessage.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
