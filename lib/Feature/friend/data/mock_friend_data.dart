import '../domain/entities/friend_entities.dart';

class MockFriendData {
  static const List<FriendRequest> mockRequests = [
    FriendRequest(
      id: 'req_1',
      name: 'Minh Hoàng',
      subtitle: 'Gợi ý từ bạn bè',
    ),
    FriendRequest(
      id: 'req_2',
      name: 'Thu Hà',
      subtitle: 'Bạn có thể biết',
    ),
  ];

  static const List<FriendItem> mockFriends = [
    FriendItem(
      id: 'f_1',
      name: 'Nguyễn Văn Nam',
      status: 'Đang hoạt động',
      isOnline: true,
    ),
    FriendItem(
      id: 'f_2',
      name: 'Phạm Thị Mai',
      status: 'Đang hoạt động',
      isOnline: true,
    ),
    FriendItem(
      id: 'f_3',
      name: 'Trần Đức Huy',
      status: 'Offline 2 giờ',
      isOnline: false,
    ),
    FriendItem(
      id: 'f_4',
      name: 'Lê Thị Hương',
      status: 'Đang hoạt động',
      isOnline: true,
    ),
    FriendItem(
      id: 'f_5',
      name: 'Hoàng Anh',
      status: 'Offline 5 giờ',
      isOnline: false,
    ),
    FriendItem(
      id: 'f_6',
      name: 'Đỗ Minh Tú',
      status: 'Offline 1 ngày',
      isOnline: false,
    ),
  ];
}
