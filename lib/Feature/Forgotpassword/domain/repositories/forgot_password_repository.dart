abstract class ForgotPasswordRepository {
  Future<String> sendResetCode(String email);
  Future<String> verifyOtp({required String email, required String otp});
  Future<String> resendOtp(String email);
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    String? confirmPassword,
  });
}
