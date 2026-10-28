import '../../../../core/network/call_api_client.dart';
import '../../domain/entities/call_item.dart';

abstract class CallRemoteDataSource {
  Future<List<CallItem>> getCallHistory({int page = 1, int pageSize = 30});
  Future<bool> deleteCallHistory(int id);
}

class CallRemoteDataSourceImpl implements CallRemoteDataSource {
  final CallApiClient callApiClient;

  CallRemoteDataSourceImpl({CallApiClient? callApiClient})
      : callApiClient = callApiClient ?? CallApiClient();

  @override
  Future<List<CallItem>> getCallHistory({int page = 1, int pageSize = 30}) async {
    final rawList = await callApiClient.getCallHistory(page: page, pageSize: pageSize);
    return rawList.map((item) {
      final id = item['id']?.toString() ??
          item['callSessionId']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final name = item['targetUserName']?.toString() ??
          item['callerName']?.toString() ??
          item['name']?.toString() ??
          'Người dùng';
      final isVideo = item['callType']?.toString().toLowerCase() == 'video' ||
          item['isVideo'] == true;
      final avatarUrl = item['targetUserAvatar']?.toString() ??
          item['callerAvatar']?.toString() ??
          item['avatarUrl']?.toString();

      final status = item['status']?.toString().toLowerCase() ?? '';
      final isCaller = item['isCaller'] == true;
      CallDirection direction;
      if (isVideo) {
        direction = CallDirection.video;
      } else if (status.contains('missed') || status.contains('miss')) {
        direction = CallDirection.missed;
      } else if (isCaller || status.contains('out')) {
        direction = CallDirection.outgoing;
      } else {
        direction = CallDirection.incoming;
      }

      String timeStr = 'Vừa xong';
      if (item['createdAt'] != null || item['time'] != null) {
        final rawDate = item['createdAt']?.toString() ?? item['time']?.toString() ?? '';
        try {
          final dt = DateTime.parse(rawDate).toLocal();
          timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          timeStr = rawDate.isNotEmpty ? rawDate : 'Hôm nay';
        }
      }

      final targetUserId = item['otherUserId'] is int
          ? item['otherUserId'] as int
          : int.tryParse(item['otherUserId']?.toString() ??
              item['targetUserId']?.toString() ??
              '');

      return CallItem(
        id: id,
        name: name,
        time: timeStr,
        direction: direction,
        isVideo: isVideo,
        avatarUrl: avatarUrl,
        targetUserId: targetUserId,
      );
    }).toList();
  }

  @override
  Future<bool> deleteCallHistory(int id) async {
    return callApiClient.deleteCallHistory(id);
  }
}
