import '../../domain/repositories/forgot_password_repository.dart';
import '../datasources/forgot_password_remote_datasource.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ForgotPasswordRemoteDataSource remoteDataSource;

  ForgotPasswordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendResetCode(String email) {
    return remoteDataSource.sendResetCode(email);
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) {
    return remoteDataSource.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<String> resendOtp(String email) {
    return remoteDataSource.resendOtp(email);
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    String? confirmPassword,
  }) {
    return remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
