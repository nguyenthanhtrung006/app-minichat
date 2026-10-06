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
  @override
  Future<UserModel> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) async {
    // Simulated remote network request
    await Future.delayed(const Duration(milliseconds: 600));

    if (password.length < 6) {
      throw Exception('Mật khẩu phải có tối thiểu 6 ký tự');
    }

    return UserModel(
      id: 'user_123',
      emailOrPhone: emailOrPhone,
      fullName: 'Người dùng Mini Chat',
    );
  }

  @override
  Future<UserModel> loginWithSocial(SocialProvider provider) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return UserModel(
      id: 'social_${provider.name}_123',
      emailOrPhone: 'user@${provider.name}.com',
      fullName: '${provider == SocialProvider.google ? "Google" : "Facebook"} User',
    );
  }
}
