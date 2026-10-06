abstract class ForgotPasswordRepository {
  Future<bool> sendResetCode(String emailOrPhone);
}
