import '../entities/message_item.dart';
import '../repositories/chat_detail_repository.dart';

class GetMessagesUseCase {
  final ChatDetailRepository repository;

  const GetMessagesUseCase({required this.repository});

  Future<List<MessageItem>> call(String contactName) async {
    return await repository.getMessages(contactName);
  }
}

class SendMessageUseCase {
  final ChatDetailRepository repository;

  const SendMessageUseCase({required this.repository});

  Future<MessageItem> call({
    required String contactName,
    required String text,
  }) async {
    return await repository.sendMessage(
      contactName: contactName,
      text: text,
    );
  }
}
