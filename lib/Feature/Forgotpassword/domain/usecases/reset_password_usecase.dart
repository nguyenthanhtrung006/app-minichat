import '../repositories/forgot_password_repository.dart';

class ResetPasswordUseCase {
  final ForgotPasswordRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<String> call({
    required String email,
    required String otp,
    required String newPassword,
    String? confirmPassword,
  }) {
    return repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
