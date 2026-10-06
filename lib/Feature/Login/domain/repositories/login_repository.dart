import '../entities/user_entity.dart';

enum SocialProvider { google, facebook }

/// Contract for Login operations.
abstract class LoginRepository {
  Future<UserEntity> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  });

  Future<UserEntity> loginWithSocial(SocialProvider provider);
}
