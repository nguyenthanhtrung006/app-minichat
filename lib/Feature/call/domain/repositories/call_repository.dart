import '../entities/call_item.dart';

abstract class CallRepository {
  Future<List<CallItem>> getCallHistory();
}
