import '../domain/entities/message_item.dart';

class MockMessageData {
  static List<MessageItem> getInitialMessages(String contactName) {
    return [
      MessageItem(
        id: 'm_1',
        text: 'Chào bạn! 👋',
        time: '09:15',
        isMe: false,
        senderName: contactName,
      ),
      const MessageItem(
        id: 'm_2',
        text: 'Chào Nam!\nBạn khỏe không?',
        time: '09:16',
        isMe: true,
        senderName: 'Tôi',
      ),
      MessageItem(
        id: 'm_3',
        text: 'Khỏe nha 😊\nHôm nay có rảnh không?',
        time: '09:17',
        isMe: false,
        senderName: contactName,
      ),
      const MessageItem(
        id: 'm_4',
        text: 'Có chứ!\nBạn rủ đi cafe không?',
        time: '09:18',
        isMe: true,
        senderName: 'Tôi',
      ),
      MessageItem(
        id: 'm_5',
        text: 'Ok luôn! 10h gặp nha\nQuán quen đó nhé 😊',
        time: '09:19',
        isMe: false,
        senderName: contactName,
      ),
      const MessageItem(
        id: 'm_6',
        text: 'Được rồi, mình đến sớm chút nhé!',
        time: '09:20',
        isMe: true,
        senderName: 'Tôi',
      ),
    ];
  }
}
