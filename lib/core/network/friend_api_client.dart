import 'dart:async';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// [FriendApiClient] - Service quản lý tất cả thao tác Gọi API Bạn bè & QR code:
/// - getFriends() -> GET /api/Friend (Đồng bộ danh sách bạn bè từ Database)
/// - getFriendRequests() -> GET /api/Friend/requests (Lấy lời mời kết bạn từ Database)
/// - getMyQr() -> GET /api/Friend/my-qr
/// - scanQr(qrData) -> GET /api/Friend/scan-qr?qrData=...
/// - sendFriendRequest(...) -> POST /api/Friend/request
/// - acceptFriendRequest(id) -> POST /api/Friend/accept/{id}
/// - rejectFriendRequest(id) -> POST /api/Friend/reject/{id}
class FriendApiClient {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  FriendApiClient({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : apiClient = apiClient ?? ApiClient(),
        tokenStorage = tokenStorage ?? TokenStorage.instance;

  /// 1. Lấy danh sách bạn bè chính thức từ Database backend
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiConstants.friendListEndpoint,
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
      debugPrint('⚠️ [FriendApiClient.getFriends]: Lỗi lấy bạn bè từ server: $e');
      rethrow;
    }
  }

  /// 2. Lấy danh sách lời mời kết bạn từ Database backend
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiConstants.friendRequestsEndpoint,
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
      debugPrint('⚠️ [FriendApiClient.getFriendRequests]: Lỗi lấy lời mời kết bạn từ server: $e');
      rethrow;
    }
  }

  /// 3. Lấy thông tin mã QR cá nhân từ Server
  Future<Map<String, dynamic>?> getMyQr() async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiConstants.myQrEndpoint,
        requiresAuth: true,
      );

      if (response.success && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [FriendApiClient.getMyQr]: Lỗi lấy mã QR từ server: $e');
      return null;
    }
  }

  /// 4. Quét và tra cứu thông tin mã QR từ Server
  Future<Map<String, dynamic>?> scanQr(String qrData) async {
    try {
      final encoded = Uri.encodeComponent(qrData);
      final response = await apiClient.get<dynamic>(
        '${ApiConstants.scanQrEndpoint}?qrData=$encoded',
        requiresAuth: true,
      );

      if (response.success && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [FriendApiClient.scanQr]: Lỗi tra cứu QR từ server: $e');
      return null;
    }
  }

  /// 5. Gửi lời mời kết bạn lên Server Database
  Future<Map<String, dynamic>?> sendFriendRequest({
    int? targetUserId,
    String? qrData,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (targetUserId != null) body['targetUserId'] = targetUserId;
      if (qrData != null) body['qrData'] = qrData;

      final response = await apiClient.post<dynamic>(
        ApiConstants.sendFriendRequestEndpoint,
        body: body,
        requiresAuth: true,
      );

      if (response.success) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
        return {'success': true};
      }
      throw ApiException(
        response.message.isNotEmpty
            ? response.message
            : 'Không thể gửi lời mời kết bạn',
      );
    } catch (e) {
      debugPrint('❌ [FriendApiClient.sendFriendRequest]: $e');
      rethrow;
    }
  }

  /// 6. Chấp nhận lời mời kết bạn
  Future<bool> acceptFriendRequest(int friendshipId) async {
    try {
      final response = await apiClient.post<dynamic>(
        '${ApiConstants.acceptFriendEndpoint}/$friendshipId',
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      debugPrint('❌ [FriendApiClient.acceptFriendRequest]: $e');
      rethrow;
    }
  }

  /// 7. Từ chối lời mời kết bạn
  Future<bool> rejectFriendRequest(int friendshipId) async {
    try {
      final response = await apiClient.post<dynamic>(
        '${ApiConstants.rejectFriendEndpoint}/$friendshipId',
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      debugPrint('❌ [FriendApiClient.rejectFriendRequest]: $e');
      rethrow;
    }
  }
}
