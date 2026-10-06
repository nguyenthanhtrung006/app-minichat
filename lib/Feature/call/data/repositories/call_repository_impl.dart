import '../../domain/entities/call_item.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_remote_datasource.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource remoteDataSource;

  const CallRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CallItem>> getCallHistory() async {
    return await remoteDataSource.getCallHistory();
  }
}
