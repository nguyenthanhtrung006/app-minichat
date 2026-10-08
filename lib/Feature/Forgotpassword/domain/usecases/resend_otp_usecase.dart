import '../repositories/forgot_password_repository.dart';

class ResendOtpUseCase {
  final ForgotPasswordRepository repository;

  ResendOtpUseCase({required this.repository});

  Future<String> call(String email) {
    return repository.resendOtp(email);
  }
}
