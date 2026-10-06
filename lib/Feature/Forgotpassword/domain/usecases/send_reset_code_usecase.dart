import '../repositories/forgot_password_repository.dart';

class SendResetCodeUseCase {
  final ForgotPasswordRepository repository;

  SendResetCodeUseCase({required this.repository});

  Future<bool> call(String emailOrPhone) {
    return repository.sendResetCode(emailOrPhone);
  }
}
