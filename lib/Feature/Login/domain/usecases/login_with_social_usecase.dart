import '../entities/user_entity.dart';
import '../repositories/login_repository.dart';

class LoginWithSocialUseCase {
  final LoginRepository repository;

  LoginWithSocialUseCase({required this.repository});

  Future<UserEntity> call(SocialProvider provider) {
    return repository.loginWithSocial(provider);
  }
}
