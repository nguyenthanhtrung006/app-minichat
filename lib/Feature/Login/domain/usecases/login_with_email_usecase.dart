import '../entities/user_entity.dart';
import '../repositories/login_repository.dart';

class LoginWithEmailUseCase {
  final LoginRepository repository;

  LoginWithEmailUseCase({required this.repository});

  Future<UserEntity> call({
    required String emailOrPhone,
    required String password,
  }) {
    return repository.loginWithEmailOrPhone(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }
}
