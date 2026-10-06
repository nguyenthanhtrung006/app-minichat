import '../../domain/entities/call_item.dart';
import '../mock_call_data.dart';

abstract class CallRemoteDataSource {
  Future<List<CallItem>> getCallHistory();
}

class CallRemoteDataSourceImpl implements CallRemoteDataSource {
  @override
  Future<List<CallItem>> getCallHistory() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<CallItem>.from(MockCallData.mockCalls);
  }
}
