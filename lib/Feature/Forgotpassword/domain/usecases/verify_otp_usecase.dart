import '../repositories/forgot_password_repository.dart';

class VerifyOtpUseCase {
  final ForgotPasswordRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<String> call({required String email, required String otp}) {
    return repository.verifyOtp(email: email, otp: otp);
  }
}
