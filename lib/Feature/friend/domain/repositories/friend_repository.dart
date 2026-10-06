import '../entities/friend_entities.dart';

abstract class FriendRepository {
  Future<List<FriendRequest>> getFriendRequests();
  Future<List<FriendItem>> getFriends();
  Future<void> toggleFriendRequest(String id);
}
