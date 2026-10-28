import '../entities/call_item.dart';

abstract class CallRepository {
  Future<List<CallItem>> getCallHistory({int page = 1, int pageSize = 30});
}
