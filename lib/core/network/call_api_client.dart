import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

/// [CallApiClient] - Quản lý các REST API liên quan đến cuộc gọi (/api/Call):
/// - getCallHistory() -> GET /api/Call/history?page=1&pageSize=30
/// - deleteCallHistory(id) -> DELETE /api/Call/history/{id}
/// - getIceServers() -> GET /api/Call/ice-servers
/// - endCall(callSessionId) -> POST /api/Call/end/{callSessionId}
class CallApiClient {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  CallApiClient({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : apiClient = apiClient ?? ApiClient(),
        tokenStorage = tokenStorage ?? TokenStorage.instance;

  /// Lấy danh sách lịch sử cuộc gọi phân trang từ Backend Database
  Future<List<Map<String, dynamic>>> getCallHistory({
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return [];
      }
      final endpoint = '${ApiConstants.callHistoryEndpoint}?page=$page&pageSize=$pageSize';
      final response = await apiClient.get<dynamic>(
        endpoint,
        requiresAuth: true,
      );

      if (response.success) {
        if (response.data is List) {
          final list = response.data as List;
          return list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else if (response.data is Map && (response.data['items'] is List || response.data['data'] is List)) {
          final list = (response.data['items'] ?? response.data['data']) as List;
          return list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ [CallApiClient.getCallHistory]: Lỗi lấy lịch sử cuộc gọi: $e');
      return [];
    }
  }

  /// Xóa 1 bản ghi lịch sử cuộc gọi
  Future<bool> deleteCallHistory(int id) async {
    try {
      final endpoint = '${ApiConstants.callHistoryEndpoint}/$id';
      final response = await apiClient.delete<dynamic>(
        endpoint,
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      debugPrint('⚠️ [CallApiClient.deleteCallHistory]: Lỗi xóa cuộc gọi $id: $e');
      return false;
    }
  }

  /// Lấy danh sách STUN/TURN ICE Servers từ backend
  Future<List<Map<String, dynamic>>> getIceServers() async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiConstants.callIceServersEndpoint,
        requiresAuth: true,
      );

      if (response.success && response.data is List) {
        final list = response.data as List;
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ [CallApiClient.getIceServers]: Lỗi lấy ICE servers: $e');
      return [];
    }
  }

  /// API dự phòng kết thúc cuộc gọi khi WebSocket mất mạng
  Future<bool> endCall(String callSessionId) async {
    try {
      final endpoint = '${ApiConstants.callEndEndpoint}/$callSessionId';
      final response = await apiClient.post<dynamic>(
        endpoint,
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      debugPrint('⚠️ [CallApiClient.endCall]: Lỗi kết thúc cuộc gọi qua REST API: $e');
      return false;
    }
  }
}
