import '../../domain/entities/friend_entities.dart';
import '../mock_friend_data.dart';

abstract class FriendRemoteDataSource {
  Future<List<FriendRequest>> getFriendRequests();
  Future<List<FriendItem>> getFriends();
  Future<void> toggleFriendRequest(String id);
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final List<FriendRequest> _requests = List.of(MockFriendData.mockRequests);
  final List<FriendItem> _friends = List.of(MockFriendData.mockFriends);

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return List.of(_requests);
  }

  @override
  Future<List<FriendItem>> getFriends() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return List.of(_friends);
  }

  @override
  Future<void> toggleFriendRequest(String id) async {
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(isSent: !_requests[idx].isSent);
    }
  }
}
