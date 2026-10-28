import '../entities/call_item.dart';
import '../repositories/call_repository.dart';

class GetCallHistoryUseCase {
  final CallRepository repository;

  const GetCallHistoryUseCase({required this.repository});

  Future<List<CallItem>> call({int page = 1, int pageSize = 30}) async {
    return await repository.getCallHistory(page: page, pageSize: pageSize);
  }
}
