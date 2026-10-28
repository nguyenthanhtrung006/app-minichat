import '../../domain/entities/friend_entities.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friend_remote_datasource.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  const FriendRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    return await remoteDataSource.getFriendRequests();
  }

  @override
  Future<List<FriendItem>> getFriends() async {
    return await remoteDataSource.getFriends();
  }

  @override
  Future<void> toggleFriendRequest(String id) async {
    await remoteDataSource.toggleFriendRequest(id);
  }

  @override
  Future<void> addFriend(FriendItem friend) async {
    await remoteDataSource.addFriend(friend);
  }

  @override
  Future<void> addFriendRequest(FriendRequest request) async {
    await remoteDataSource.addFriendRequest(request);
  }

  @override
  Stream<List<FriendItem>> get friendsStream => remoteDataSource.friendsStream;

  @override
  Stream<List<FriendRequest>> get requestsStream =>
      remoteDataSource.requestsStream;
}
