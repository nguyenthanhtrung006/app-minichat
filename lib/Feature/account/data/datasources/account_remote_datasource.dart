import 'package:minichatapp/core/network/auth_api_client.dart';
import '../../domain/entities/user_profile.dart';

abstract class AccountRemoteDataSource {
  Future<UserProfile> getUserProfile();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final AuthApiClient authApiClient;

  AccountRemoteDataSourceImpl({AuthApiClient? authApiClient})
      : authApiClient = authApiClient ?? AuthApiClient();

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      // Gọi API GET /api/auth/me với Bearer Token
      final user = await authApiClient.getMe();

      return UserProfile(
        id: user.id.toString(),
        fullName: user.fullName.isNotEmpty ? user.fullName : 'Người dùng Mini Chat',
        username: user.email,
        bio: user.bio ?? 'Xin chào, tôi là thành viên Mini Chat!',
        friendsCount: 0,
        postsCount: 0,
        groupsCount: 0,
        isOnline: user.isOnline,
        avatarUrl: user.avatarUrl,
        coverUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
      );
    } catch (_) {
      // Trường hợp chưa đăng nhập hoặc lỗi, hiển thị hồ sơ mặc định
      return const UserProfile(
        id: '1',
        fullName: 'Người dùng Mini Chat',
        username: 'user@gmail.com',
        bio: 'Xin chào, tôi là thành viên Mini Chat!',
        friendsCount: 0,
        postsCount: 0,
        groupsCount: 0,
        isOnline: true,
        coverUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
      );
    }
  }
}
