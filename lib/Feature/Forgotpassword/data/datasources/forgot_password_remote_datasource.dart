import '../../../../core/network/auth_api_client.dart';

abstract class ForgotPasswordRemoteDataSource {
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

class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  final AuthApiClient authApiClient;

  ForgotPasswordRemoteDataSourceImpl({AuthApiClient? authApiClient})
      : authApiClient = authApiClient ?? AuthApiClient();

  @override
  Future<String> sendResetCode(String email) async {
    return await authApiClient.forgotPassword(email: email);
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    return await authApiClient.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<String> resendOtp(String email) async {
    return await authApiClient.resendOtp(email: email);
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    String? confirmPassword,
  }) async {
    return await authApiClient.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
