import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  const AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getUserProfile() async {
    return await remoteDataSource.getUserProfile();
  }
}
