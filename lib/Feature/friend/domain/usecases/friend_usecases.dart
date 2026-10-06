import '../repositories/friend_repository.dart';

class GetFriendDataUseCase {
  final FriendRepository repository;

  const GetFriendDataUseCase({required this.repository});

  Future<Map<String, dynamic>> call() async {
    final requests = await repository.getFriendRequests();
    final friends = await repository.getFriends();
    return {
      'requests': requests,
      'friends': friends,
    };
  }
}

class ToggleFriendRequestUseCase {
  final FriendRepository repository;

  const ToggleFriendRequestUseCase({required this.repository});

  Future<void> call(String id) async {
    await repository.toggleFriendRequest(id);
  }
}
