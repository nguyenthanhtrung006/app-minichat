import '../../domain/entities/message_item.dart';
import '../../domain/repositories/chat_detail_repository.dart';
import '../datasources/chat_detail_remote_datasource.dart';

class ChatDetailRepositoryImpl implements ChatDetailRepository {
  final ChatDetailRemoteDataSource remoteDataSource;

  const ChatDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MessageItem>> getMessages(String contactName) async {
    return await remoteDataSource.getMessages(contactName);
  }

  @override
  Future<MessageItem> sendMessage({
    required String contactName,
    required String text,
  }) async {
    return await remoteDataSource.sendMessage(
      contactName: contactName,
      text: text,
    );
  }
}
