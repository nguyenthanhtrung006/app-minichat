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
}
