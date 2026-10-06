import '../../domain/repositories/forgot_password_repository.dart';
import '../datasources/forgot_password_remote_datasource.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ForgotPasswordRemoteDataSource remoteDataSource;

  ForgotPasswordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> sendResetCode(String emailOrPhone) {
    return remoteDataSource.sendResetCode(emailOrPhone);
  }
}
