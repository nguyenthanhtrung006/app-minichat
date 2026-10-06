import '../../domain/entities/user_profile.dart';

abstract class AccountRemoteDataSource {
  Future<UserProfile> getUserProfile();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  @override
  Future<UserProfile> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const UserProfile(
      id: 'u_1',
      fullName: 'Nguyễn Văn Nam',
      username: '@nguyenvannam',
      bio: 'Sống tích cực - Làm điều mình thích ☀️',
      friendsCount: 128,
      postsCount: 56,
      groupsCount: 12,
      isOnline: true,
      coverUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
    );
  }
}
