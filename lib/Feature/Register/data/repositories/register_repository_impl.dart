import '../../domain/entities/register_params.dart';
import '../../domain/repositories/register_repository.dart';
import '../datasources/register_remote_datasource.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource remoteDataSource;

  RegisterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> register(RegisterParams params) {
    return remoteDataSource.registerUser(params);
  }
}
