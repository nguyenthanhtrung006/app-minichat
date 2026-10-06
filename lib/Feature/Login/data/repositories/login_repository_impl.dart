import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) {
    return remoteDataSource.loginWithEmailOrPhone(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }

  @override
  Future<UserEntity> loginWithSocial(SocialProvider provider) {
    return remoteDataSource.loginWithSocial(provider);
  }
}
