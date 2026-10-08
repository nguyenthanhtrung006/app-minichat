import 'package:minichatapp/core/network/auth_api_client.dart';
import '../../domain/repositories/login_repository.dart';
import '../models/user_model.dart';

abstract class LoginRemoteDataSource {
  Future<UserModel> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  });

  Future<UserModel> loginWithSocial(SocialProvider provider);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final AuthApiClient authApiClient;

  LoginRemoteDataSourceImpl({AuthApiClient? authApiClient})
      : authApiClient = authApiClient ?? AuthApiClient();

  @override
  Future<UserModel> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) async {
    // Gọi API thật tới https://api.trungmobileapp.id.vn/api/auth/login
    final result = await authApiClient.login(
      email: emailOrPhone,
      password: password,
    );
    return result.user;
  }

  @override
  Future<UserModel> loginWithSocial(SocialProvider provider) async {
    // API hiện tại theo Docs tập trung vào Email/Password
    // Dự phòng cho Social login khi backend hỗ trợ
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel(
      id: 9999,
      email: 'user@${provider.name}.com',
      fullName: '${provider == SocialProvider.google ? "Google" : "Facebook"} User',
      isOnline: true,
    );
  }
}
