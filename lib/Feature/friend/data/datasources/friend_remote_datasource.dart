import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/friend_entities.dart';
import '../../../../core/network/signalr_service.dart';
import '../../../../core/network/friend_api_client.dart';
import '../../../../core/storage/token_storage.dart';

abstract class FriendRemoteDataSource {
  Future<List<FriendRequest>> getFriendRequests();
  Future<List<FriendItem>> getFriends();
  Future<void> toggleFriendRequest(String id);
  Future<void> addFriend(FriendItem friend);
  Future<void> addFriendRequest(FriendRequest request);
  Future<void> syncWithDatabase();
  void clearCache();
  Stream<List<FriendItem>> get friendsStream;
  Stream<List<FriendRequest>> get requestsStream;
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  static final FriendRemoteDataSourceImpl _instance =
      FriendRemoteDataSourceImpl._internal();
  static FriendRemoteDataSourceImpl get instance => _instance;

  final FlutterSecureStorage _storage;
  final FriendApiClient _friendApiClient;
  final TokenStorage _tokenStorage;

  final List<FriendRequest> _requests = [];
  final List<FriendItem> _friends = [];
  bool _isLoaded = false;
  String? _lastLoadedUserId;

  final StreamController<List<FriendItem>> _friendsStreamController =
      StreamController<List<FriendItem>>.broadcast();
  final StreamController<List<FriendRequest>> _requestsStreamController =
      StreamController<List<FriendRequest>>.broadcast();

  @override
  Stream<List<FriendItem>> get friendsStream => _friendsStreamController.stream;

  @override
  Stream<List<FriendRequest>> get requestsStream =>
      _requestsStreamController.stream;

  factory FriendRemoteDataSourceImpl({
    FriendApiClient? friendApiClient,
    TokenStorage? tokenStorage,
    FlutterSecureStorage? storage,
  }) {
    return _instance;
  }

  FriendRemoteDataSourceImpl._internal({
    FriendApiClient? friendApiClient,
    TokenStorage? tokenStorage,
    FlutterSecureStorage? storage,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _friendApiClient = friendApiClient ?? FriendApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage.instance {
    _loadFromStorage();

    // 1. Lắng nghe trạng thái online/offline của bạn bè từ SignalR
    SignalRService.instance.onlineStatusStream.listen((data) {
      if (data is Map) {
        final isOnline = data['isOnline'] as bool? ?? false;
        final userId = data['userId']?.toString();
        var updated = false;
        for (var i = 0; i < _friends.length; i++) {
          if (_friends[i].id == userId) {
            _friends[i] = _friends[i].copyWith(
              isOnline: isOnline,
              status: isOnline ? 'Đang hoạt động' : 'Offline',
            );
            updated = true;
          }
        }
        if (updated) {
          _notifyFriends();
        }
      }
    });

    // 2. Lắng nghe sự kiện Lời mời kết bạn Realtime từ SignalR Hub
    SignalRService.instance.friendRequestStream.listen((data) {
      debugPrint('🤝 [FriendRemoteDataSource]: Nhận thông báo kết bạn mới qua SignalR! Đồng bộ ngay từ Database...');
      syncWithDatabase();
    });
  }

  bool get _isTestEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  String _getFriendsKey(String? userId) => 'minichat_saved_friends_${userId ?? "default"}';
  String _getRequestsKey(String? userId) => 'minichat_saved_requests_${userId ?? "default"}';

  @override
  void clearCache() {
    _friends.clear();
    _requests.clear();
    _isLoaded = false;
    _lastLoadedUserId = null;
    _notifyFriends();
    _notifyRequests();
  }

  Future<void> _loadFromStorage() async {
    final currentUserId = SignalRService.instance.currentUserId;
    if (_isLoaded && _lastLoadedUserId == currentUserId) return;
    if (_isTestEnvironment) {
      _isLoaded = true;
      _lastLoadedUserId = currentUserId;
      return;
    }

    try {
      final friendsRaw = await _storage
          .read(key: _getFriendsKey(currentUserId))
          .timeout(const Duration(milliseconds: 250), onTimeout: () => null);
      if (friendsRaw != null && friendsRaw.isNotEmpty) {
        final decoded = jsonDecode(friendsRaw) as List;
        _friends.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _friends.add(FriendItem.fromJson(item));
          }
        }
      }

      final requestsRaw = await _storage
          .read(key: _getRequestsKey(currentUserId))
          .timeout(const Duration(milliseconds: 250), onTimeout: () => null);
      if (requestsRaw != null && requestsRaw.isNotEmpty) {
        final decoded = jsonDecode(requestsRaw) as List;
        _requests.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _requests.add(FriendRequest.fromJson(item));
          }
        }
      }

      _isLoaded = true;
      _lastLoadedUserId = currentUserId;
      _notifyFriends();
      _notifyRequests();
    } catch (e) {
      debugPrint('⚠️ [FriendRemoteDataSource]: Lỗi tải danh sách bạn bè đã lưu: $e');
      _isLoaded = true;
      _lastLoadedUserId = currentUserId;
    }
  }

  Future<void> _saveToStorage() async {
    if (_isTestEnvironment) return;
    try {
      final currentUserId = SignalRService.instance.currentUserId;
      final friendsJson = jsonEncode(_friends.map((f) => f.toJson()).toList());
      await _storage
          .write(key: _getFriendsKey(currentUserId), value: friendsJson)
          .timeout(const Duration(milliseconds: 200), onTimeout: () {});

      final requestsJson =
          jsonEncode(_requests.map((r) => r.toJson()).toList());
      await _storage
          .write(key: _getRequestsKey(currentUserId), value: requestsJson)
          .timeout(const Duration(milliseconds: 200), onTimeout: () {});
    } catch (e) {
      debugPrint('⚠️ [FriendRemoteDataSource]: Lỗi lưu danh sách bạn bè: $e');
    }
  }

  void _notifyFriends() {
    if (!_friendsStreamController.isClosed) {
      _friendsStreamController.add(List.unmodifiable(_friends));
    }
  }

  void _notifyRequests() {
    if (!_requestsStreamController.isClosed) {
      _requestsStreamController.add(List.unmodifiable(_requests));
    }
  }

  /// Đồng bộ danh sách bạn bè và lời mời kết bạn từ Server Database
  @override
  Future<void> syncWithDatabase() async {
    if (_isTestEnvironment) return;
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return;

    try {
      // 1. Lấy danh sách bạn bè từ Database: GET /api/Friend
      final remoteFriendsRaw = await _friendApiClient.getFriends();
      final List<FriendItem> remoteFriends = [];
      for (final item in remoteFriendsRaw) {
        final user = item['user'] is Map ? item['user'] as Map : item;
        final id = user['id']?.toString() ?? item['friendshipId']?.toString() ?? '';
        final name = user['fullName']?.toString() ?? 'Người dùng';
        final isOnline = user['isOnline'] == true;
        final avatarUrl = user['avatarUrl']?.toString();
        remoteFriends.add(
          FriendItem(
            id: id,
            name: name,
            status: isOnline ? 'Đang hoạt động' : 'Offline',
            isOnline: isOnline,
            avatarUrl: avatarUrl,
          ),
        );
      }

      // Hợp nhất danh sách bạn bè
      for (final rf in remoteFriends) {
        final idx = _friends.indexWhere((f) => f.id == rf.id || f.name == rf.name);
        if (idx != -1) {
          _friends[idx] = rf;
        } else {
          _friends.add(rf);
        }
      }

      // 2. Lấy danh sách lời mời kết bạn từ Database: GET /api/Friend/requests
      final remoteRequestsRaw = await _friendApiClient.getFriendRequests();
      final List<FriendRequest> remoteRequests = [];
      for (final item in remoteRequestsRaw) {
        final isIncoming = item['isIncoming'] == true;
        final target = isIncoming ? item['fromUser'] : item['toUser'];
        final targetMap = target is Map ? target : {};
        final name = targetMap['fullName']?.toString() ?? 'Người dùng';
        final avatarUrl = targetMap['avatarUrl']?.toString();
        final friendshipId = item['friendshipId']?.toString() ?? '';
        final subtitle = isIncoming ? 'Đã gửi lời mời kết bạn' : 'Lời mời đã gửi';
        remoteRequests.add(
          FriendRequest(
            id: friendshipId,
            name: name,
            subtitle: subtitle,
            avatarUrl: avatarUrl,
            isSent: !isIncoming,
          ),
        );
      }

      // Cập nhật danh sách lời mời
      if (remoteRequests.isNotEmpty) {
        _requests.clear();
        _requests.addAll(remoteRequests);
      }

      await _saveToStorage();
      _notifyFriends();
      _notifyRequests();
      debugPrint('🎉 [FriendRemoteDataSource]: Đồng bộ thành công ${_friends.length} bạn bè và ${_requests.length} lời mời từ Database.');
    } catch (e) {
      debugPrint('⚠️ [FriendRemoteDataSource]: Không thể đồng bộ từ backend ($e), giữ dữ liệu đã lưu.');
    }
  }

  @override
  Future<void> addFriend(FriendItem friend) async {
    await _loadFromStorage();
    final idx = _friends.indexWhere(
      (f) => (f.id.isNotEmpty && f.id == friend.id) || f.name == friend.name,
    );
    if (idx != -1) {
      _friends[idx] = friend;
    } else {
      _friends.insert(0, friend);
    }

    // Nếu người này đang ở danh sách chờ, cập nhật thành đã kết nối
    _requests.removeWhere((r) => r.id == friend.id || r.name == friend.name);

    await _saveToStorage();
    _notifyFriends();
    _notifyRequests();

    // Đồng bộ lên database nếu có targetUserId
    final targetId = int.tryParse(friend.id);
    if (!_isTestEnvironment && targetId != null && targetId > 0) {
      try {
        await _friendApiClient.sendFriendRequest(targetUserId: targetId);
      } catch (_) {}
    }
  }

  @override
  Future<void> addFriendRequest(FriendRequest request) async {
    await _loadFromStorage();
    final idx = _requests.indexWhere((r) => r.id == request.id);
    if (idx == -1) {
      _requests.insert(0, request);
    } else {
      _requests[idx] = request;
    }

    await _saveToStorage();
    _notifyRequests();
  }

  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    await _loadFromStorage();
    // Đồng bộ ngầm từ database khi có kết nối
    if (!_isTestEnvironment) {
      unawaited(syncWithDatabase());
    }
    return List.of(_requests);
  }

  @override
  Future<List<FriendItem>> getFriends() async {
    await _loadFromStorage();
    // Đồng bộ ngầm từ database khi có kết nối
    if (!_isTestEnvironment) {
      unawaited(syncWithDatabase());
    }
    return List.of(_friends);
  }

  @override
  Future<void> toggleFriendRequest(String id) async {
    await _loadFromStorage();
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final req = _requests[idx];
      // Nếu là lời mời nhận được (chưa gửi), chấp nhận lời mời trên Backend
      final friendshipId = int.tryParse(id);
      if (!_isTestEnvironment && !req.isSent && friendshipId != null) {
        try {
          await _friendApiClient.acceptFriendRequest(friendshipId);
          debugPrint('✅ [toggleFriendRequest]: Đã chấp nhận lời mời kết bạn #$friendshipId trên Server.');
          // Thêm người bạn này vào danh sách bạn bè
          final newFriend = FriendItem(
            id: req.id,
            name: req.name,
            status: 'Đang hoạt động',
            isOnline: true,
            avatarUrl: req.avatarUrl,
          );
          await addFriend(newFriend);
          await syncWithDatabase();
          return;
        } catch (e) {
          debugPrint('⚠️ [toggleFriendRequest]: Lỗi chấp nhận lời mời: $e');
        }
      }

      _requests[idx] = _requests[idx].copyWith(isSent: !_requests[idx].isSent);
      await _saveToStorage();
      _notifyRequests();
    }
  }
}
