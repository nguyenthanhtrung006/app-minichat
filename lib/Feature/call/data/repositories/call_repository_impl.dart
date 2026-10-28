import '../../domain/entities/call_item.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_remote_datasource.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource remoteDataSource;

  const CallRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CallItem>> getCallHistory({int page = 1, int pageSize = 30}) async {
    return await remoteDataSource.getCallHistory(page: page, pageSize: pageSize);
  }
}
