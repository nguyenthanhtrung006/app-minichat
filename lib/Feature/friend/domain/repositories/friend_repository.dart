import '../entities/friend_entities.dart';

abstract class FriendRepository {
  Future<List<FriendRequest>> getFriendRequests();
  Future<List<FriendItem>> getFriends();
  Future<void> toggleFriendRequest(String id);
  Future<void> addFriend(FriendItem friend);
  Future<void> addFriendRequest(FriendRequest request);
  Stream<List<FriendItem>> get friendsStream;
  Stream<List<FriendRequest>> get requestsStream;
}
