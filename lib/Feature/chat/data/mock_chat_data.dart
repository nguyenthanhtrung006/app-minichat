import '../domain/entities/chat_item.dart';

class MockChatData {
  static const List<ChatItem> mockChats = [
    ChatItem(
      id: '1',
      name: 'Nguyễn Văn Nam',
      lastMessage: 'Ok, để mình xem lại nhé!',
      time: '20:15',
      unreadCount: 2,
      isOnline: true,
    ),
    ChatItem(
      id: '2',
      name: 'Phạm Thị Mai',
      lastMessage: 'Bạn: Hình ảnh',
      time: '19:48',
      unreadCount: 1,
      hasPhoto: true,
    ),
    ChatItem(
      id: '3',
      name: 'Nhóm Lớp 12A',
      lastMessage: 'Tuấn: mai chúng ta họp nhé mọi người',
      time: '18:32',
      unreadCount: 5,
      isGroup: true,
    ),
    ChatItem(
      id: '4',
      name: 'Trần Đức Huy',
      lastMessage: 'Đã gửi một file tài liệu',
      time: '16:20',
      unreadCount: 1,
    ),
    ChatItem(
      id: '5',
      name: 'Lê Thị Hương',
      lastMessage: 'Cảm ơn bạn nhiều!',
      time: '14:17',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatItem(
      id: '6',
      name: 'Hoàng Anh',
      lastMessage: 'Bạn: Ok luôn!',
      time: '12:03',
      unreadCount: 0,
    ),
    ChatItem(
      id: '7',
      name: 'Thu Hà',
      lastMessage: 'Cuộc gọi nhỡ',
      time: '10:21',
      unreadCount: 0,
      isMissedCall: true,
    ),
    ChatItem(
      id: '8',
      name: 'Minh Hoàng',
      lastMessage: 'Hẹn gặp bạn chiều nay nhé!',
      time: '09:45',
      unreadCount: 0,
    ),
    ChatItem(
      id: '9',
      name: 'Đỗ Minh Tú',
      lastMessage: 'Bạn: Được rồi, cảm ơn bạn!',
      time: 'Hôm qua',
      unreadCount: 0,
    ),
  ];
}
