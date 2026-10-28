import '../domain/entities/message_item.dart';

class MockMessageData {
  static List<MessageItem> getInitialMessages(String contactName) {
    // Không gán dữ liệu cứng, tin nhắn bắt đầu trống và trao đổi trực tiếp realtime
    return [];
  }
}
