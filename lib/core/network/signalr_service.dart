import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../constants/api_constants.dart';
import '../session/auth_session_manager.dart';
import '../storage/token_storage.dart';

/// Service quản lý kết nối SignalR Realtime với ASP.NET Core backend.
/// Cung cấp các tính năng:
/// - Kết nối Hub với JWT Bearer Token qua accessTokenFactory
/// - Lắng nghe tin nhắn mới ('ReceiveMessage')
/// - Lắng nghe trạng thái đang gõ phím ('UserTyping')
/// - Lắng nghe trạng thái Online/Offline ('UserOnlineStatus')
/// - Lắng nghe và gửi thông báo kết bạn Realtime ('ReceiveFriendRequest')
/// - Thực thi Single Device Login (ngắt phiên thiết bị cũ khi máy mới đăng nhập)
/// - Gửi tin nhắn qua 'SendMessage'
/// - Báo đang soạn tin qua 'SendTyping'
/// - Tự động kết nối lại khi mất mạng (withAutomaticReconnect)
class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  static SignalRService get instance => _instance;

  final TokenStorage _tokenStorage;
  HubConnection? _hubConnection;
  String? currentUserId;
  String? currentUserEmail;

  // StreamControllers để các BLoC / UI có thể lắng nghe sự kiện dạng Stream
  final _messageController = StreamController<dynamic>.broadcast();
  final _typingController = StreamController<dynamic>.broadcast();
  final _onlineStatusController = StreamController<dynamic>.broadcast();
  final _friendRequestController = StreamController<dynamic>.broadcast();
  final _connectionStateController = StreamController<HubConnectionState>.broadcast();

  // Callbacks trực tiếp
  void Function(dynamic data)? onMessageReceived;
  void Function(dynamic data)? onUserTyping;
  void Function(dynamic data)? onUserOnlineStatus;
  void Function(dynamic data)? onFriendRequestReceived;
  void Function(HubConnectionState state)? onConnectionStateChanged;

  SignalRService._internal({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage.instance;

  factory SignalRService({TokenStorage? tokenStorage}) {
    return _instance;
  }

  /// HubConnection hiện hành
  HubConnection get hubConnection {
    if (_hubConnection == null) {
      throw StateError('SignalR HubConnection chưa được khởi tạo. Hãy gọi initSignalR() trước.');
    }
    return _hubConnection!;
  }

  /// Trạng thái kết nối hiện tại
  HubConnectionState get connectionState =>
      _hubConnection?.state ?? HubConnectionState.Disconnected;

  bool get isConnected => connectionState == HubConnectionState.Connected;

  // Streams công khai cho BLoC/Widget đăng ký lắng nghe
  Stream<dynamic> get messageStream => _messageController.stream;
  Stream<dynamic> get typingStream => _typingController.stream;
  Stream<dynamic> get onlineStatusStream => _onlineStatusController.stream;
  Stream<dynamic> get friendRequestStream => _friendRequestController.stream;
  Stream<HubConnectionState> get connectionStateStream => _connectionStateController.stream;

  /// Khởi tạo và kết nối tới SignalR Hub
  Future<void> initSignalR({
    String? customHubUrl,
    String? userId,
    String? email,
  }) async {
    if (userId != null && userId.isNotEmpty) currentUserId = userId.trim();
    if (email != null && email.isNotEmpty) currentUserEmail = email.toLowerCase().trim();

    currentUserId ??= await _tokenStorage.getUserId();
    currentUserEmail ??= await _tokenStorage.getUserEmail();

    final hubUrl = customHubUrl ?? ApiConstants.chatHubUrl;

    debugPrint('\n🔌 ==================== [SIGNALR INITIALIZING] ====================');
    debugPrint('➡️ Hub URL : $hubUrl');
    debugPrint('👤 Tài khoản : $currentUserEmail (ID: $currentUserId)');
    debugPrint('==================================================================');

    // 1. Cấu hình HttpConnectionOptions đính kèm Access Token JWT
    final options = HttpConnectionOptions(
      accessTokenFactory: () async {
        final token = await _tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          try {
            final parts = token.split('.');
            if (parts.length >= 2) {
              var payload = parts[1];
              while (payload.length % 4 != 0) {
                payload += '=';
              }
              final decoded = utf8.decode(base64Url.decode(payload));
              final map = jsonDecode(decoded);
              currentUserId ??= map['nameid']?.toString() ??
                  map['sub']?.toString() ??
                  map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']?.toString();
              currentUserEmail ??= map['email']?.toString() ??
                  map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']?.toString() ??
                  map['unique_name']?.toString();
            }
          } catch (_) {}
        }
        return token ?? '';
      },
    );

    // 2. Xây dựng HubConnection với Automatic Reconnect
    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: options)
        .withAutomaticReconnect()
        .build();

    // Lắng nghe các trạng thái vòng đời kết nối
    _hubConnection!.onreconnecting(({error}) {
      debugPrint('🔄 [SignalR]: Đang thử kết nối lại hub... Lỗi: $error');
      _notifyStateChanged(HubConnectionState.Reconnecting);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      debugPrint('✅ [SignalR]: Đã kết nối lại thành công! ID: $connectionId');
      _notifyStateChanged(HubConnectionState.Connected);
    });

    _hubConnection!.onclose(({error}) {
      debugPrint('❌ [SignalR]: Mất kết nối hub. Lỗi: $error');
      _notifyStateChanged(HubConnectionState.Disconnected);
    });

    // 1. Lắng nghe tin nhắn mới nhận được
    hubConnection.on('ReceiveMessage', (arguments) async {
      final data = (arguments != null && arguments.isNotEmpty) ? arguments[0] : null;
      debugPrint('📩 [SignalR]: Nhận tin nhắn mới: $data');

      if (data is Map) {
        final type = data['type']?.toString();
        // Kiểm tra tín hiệu phiên đăng nhập khác (Concurrent Login Kick)
        if (type == 'CONCURRENT_LOGIN_KICK') {
          final incomingSessionId = data['attachmentUrl']?.toString();

          String? incomingEmail;
          String? incomingUserId;
          String? payloadSessionId = incomingSessionId;

          try {
            final contentStr = data['content']?.toString();
            if (contentStr != null && contentStr.startsWith('{')) {
              final parsed = jsonDecode(contentStr);
              if (parsed is Map) {
                incomingEmail = parsed['email']?.toString().toLowerCase().trim();
                incomingUserId = parsed['userId']?.toString().trim();
                if (parsed['sessionId'] != null) {
                  payloadSessionId = parsed['sessionId'].toString();
                }
              }
            }
          } catch (_) {}

          final targetSessionId = payloadSessionId ?? incomingSessionId;

          // Lấy thông tin tài khoản hiện tại của thiết bị này
          final myEmail = (currentUserEmail ?? await _tokenStorage.getUserEmail())?.toLowerCase().trim();
          final myUserId = (currentUserId ?? await _tokenStorage.getUserId())?.trim();

          debugPrint('🔍 [SignalR KICK CHECK]: '
              'Incoming (email: $incomingEmail, userId: $incomingUserId, session: $targetSessionId) | '
              'Current (email: $myEmail, userId: $myUserId, session: ${AuthSessionManager.instance.deviceSessionId})');

          // ⚠️ QUY TẮC BẢO VỆ CHÍNH XÁC:
          // 1. Phải là CÙNG TÀI KHOẢN (cùng Email HOẶC cùng UserId).
          //    Nếu là tài khoản khác (email khác hoặc userId khác) -> TUYỆT ĐỐI BỎ QUA, KHÔNG HIỆN POPUP!
          bool isSameAccount = false;
          if (incomingEmail != null && incomingEmail.isNotEmpty && myEmail != null && myEmail.isNotEmpty) {
            isSameAccount = (incomingEmail == myEmail);
          }
          if (!isSameAccount && incomingUserId != null && incomingUserId.isNotEmpty && myUserId != null && myUserId.isNotEmpty) {
            isSameAccount = (incomingUserId == myUserId);
          }

          if (!isSameAccount) {
            debugPrint('🛡️ [SignalR]: Bỏ qua KICK vì KHÔNG CÙNG TÀI KHOẢN (tài khoản khác đăng nhập).');
            return;
          }

          // 2. Phải là THIẾT BỊ KHÁC:
          if (targetSessionId != null &&
              targetSessionId != AuthSessionManager.instance.deviceSessionId) {
            debugPrint('🚨 [SignalR]: CÙNG TÀI KHOẢN ($myEmail / ID: $myUserId) đã đăng nhập trên thiết bị khác ($targetSessionId)! Đang đá phiên máy này...');
            AuthSessionManager.instance.handleForceLogout(
              reason: 'Tài khoản của bạn đã được đăng nhập trên một thiết bị khác. Vui lòng đăng nhập lại!',
            );
            return;
          } else {
            debugPrint('ℹ️ [SignalR]: Lệnh KICK từ chính thiết bị này, giữ nguyên phiên.');
            return;
          }
        }

        // Kiểm tra sự kiện kết bạn Realtime
        if (type == 'FriendRequest' || type == 'FriendAccepted') {
          debugPrint('🤝 [SignalR]: Nhận sự kiện kết bạn realtime từ tin nhắn: $data');
          _friendRequestController.add(data);
          onFriendRequestReceived?.call(data);
        }
      }

      _messageController.add(data);
      onMessageReceived?.call(data);
    });

    // 2. Lắng nghe trạng thái đang soạn tin nhắn (Typing)
    hubConnection.on('UserTyping', (arguments) {
      final data = (arguments != null && arguments.isNotEmpty) ? arguments[0] : null;
      debugPrint('✍️ [SignalR]: User đang soạn tin nhắn: $data');
      _typingController.add(data);
      onUserTyping?.call(data);
    });

    // 3. Lắng nghe trạng thái Online / Offline
    hubConnection.on('UserOnlineStatus', (arguments) {
      final data = arguments?[0];
      if (data is Map) {
        debugPrint('User ${data['userId']} online: ${data['isOnline']}');
      } else {
        debugPrint('User online status update: $data');
      }
      _onlineStatusController.add(data);
      onUserOnlineStatus?.call(data);
    });

    // 4. Lắng nghe các sự kiện Lời mời kết bạn Realtime từ Backend
    for (final event in [
      'ReceiveFriendRequest',
      'FriendRequestReceived',
      'NewFriendRequest',
      'FriendAdded',
      'FriendAccepted',
      'ReceiveNotification'
    ]) {
      hubConnection.on(event, (arguments) {
        final data = (arguments != null && arguments.isNotEmpty) ? arguments[0] : null;
        debugPrint('🤝 [SignalR Event $event]: $data');
        _friendRequestController.add(data);
        onFriendRequestReceived?.call(data);
      });
    }

    // 5. Lắng nghe sự kiện Bị đăng xuất cưỡng bức do máy khác đăng nhập từ Backend Hub
    for (final event in [
      'ForceLogout',
      'ConcurrentLogin',
      'SessionTerminated',
      'UserLoggedOut',
      'MultipleDevicesDetected'
    ]) {
      hubConnection.on(event, (arguments) async {
        final data = (arguments != null && arguments.isNotEmpty) ? arguments[0] : null;
        debugPrint('🚨 [SignalR ForceLogout Event $event]: $data');

        if (data is Map) {
          final targetUserId = data['userId']?.toString() ?? data['targetUserId']?.toString();
          final targetEmail = (data['email']?.toString() ?? data['userEmail']?.toString())?.toLowerCase().trim();
          final targetSessionId = data['sessionId']?.toString() ?? data['deviceSessionId']?.toString();

          final myEmail = (currentUserEmail ?? await _tokenStorage.getUserEmail())?.toLowerCase().trim();
          final myUserId = (currentUserId ?? await _tokenStorage.getUserId())?.trim();

          if (targetUserId != null && targetUserId.isNotEmpty && myUserId != null && targetUserId != myUserId) {
            debugPrint('🛡️ [SignalR Event $event]: Bỏ qua vì targetUserId ($targetUserId) != myUserId ($myUserId).');
            return;
          }
          if (targetEmail != null && targetEmail.isNotEmpty && myEmail != null && targetEmail != myEmail) {
            debugPrint('🛡️ [SignalR Event $event]: Bỏ qua vì targetEmail ($targetEmail) != myEmail ($myEmail).');
            return;
          }
          if (targetSessionId != null && targetSessionId == AuthSessionManager.instance.deviceSessionId) {
            debugPrint('ℹ️ [SignalR Event $event]: Bỏ qua vì chính là thiết bị hiện tại.');
            return;
          }
        }

        AuthSessionManager.instance.handleForceLogout(
          reason: 'Tài khoản của bạn đã được đăng nhập trên một thiết bị khác. Vui lòng đăng nhập lại!',
        );
      });
    }

    // Bắt đầu kết nối
    try {
      await hubConnection.start();
      debugPrint('SignalR đã kết nối thành công!');
      _notifyStateChanged(HubConnectionState.Connected);
      // Gửi tín hiệu thông báo phiên đăng nhập đơn (Single Device)
      notifyConcurrentLoginOtherDevices();
    } catch (e) {
      debugPrint('⚠️ [SignalR Cảnh Báo]: Không thể kết nối tới Hub ngay bây giờ: $e');
      _notifyStateChanged(HubConnectionState.Disconnected);
    }
  }

  /// Thông báo cho các thiết bị khác cùng tài khoản biết rằng thiết bị này vừa đăng nhập
  Future<void> notifyConcurrentLoginOtherDevices() async {
    if (!isConnected) return;
    currentUserId ??= await _tokenStorage.getUserId();
    currentUserEmail ??= await _tokenStorage.getUserEmail();

    final myIdStr = currentUserId;
    final myEmail = currentUserEmail?.toLowerCase().trim();
    if (myIdStr == null && myEmail == null) return;

    final myId = int.tryParse(myIdStr ?? '0') ?? 0;

    final kickPayload = jsonEncode({
      'email': myEmail,
      'userId': myIdStr,
      'sessionId': AuthSessionManager.instance.deviceSessionId,
    });

    try {
      await hubConnection.invoke('SendMessage', args: [
        {
          'conversationId': 0,
          'receiverId': myId,
          'content': kickPayload,
          'type': 'CONCURRENT_LOGIN_KICK',
          'attachmentUrl': AuthSessionManager.instance.deviceSessionId,
        }
      ]);
      debugPrint('📡 [SignalR]: Đã gửi tín hiệu kiểm tra single-device cho tài khoản: $myEmail (ID: $myIdStr).');
    } catch (e) {
      debugPrint('⚠️ [SignalR]: Không thể gửi tín hiệu kiểm tra single device: $e');
    }
  }

  /// Gửi thông báo kết bạn Realtime cho tài khoản đích
  Future<void> sendFriendRequestNotification({
    required int targetUserId,
    required String senderName,
  }) async {
    if (!isConnected) {
      try {
        await hubConnection.start();
      } catch (_) {}
    }
    try {
      await hubConnection.invoke('SendMessage', args: [
        {
          'conversationId': 0,
          'receiverId': targetUserId,
          'receiverName': senderName,
          'content': '$senderName đã gửi lời mời kết bạn',
          'type': 'FriendRequest',
        }
      ]);
      debugPrint('🤝 [SignalR]: Đã gửi thông báo kết bạn realtime tới user $targetUserId');
    } catch (e) {
      debugPrint('⚠️ [SignalR]: Lỗi gửi thông báo kết bạn qua SendMessage: $e');
    }

    // Thử gọi SendFriendRequest trên hub nếu có
    try {
      await hubConnection.invoke('SendFriendRequest', args: [
        {'targetUserId': targetUserId}
      ]);
    } catch (_) {}
  }

  /// Gửi thông báo đã chấp nhận kết bạn Realtime cho tài khoản người gửi
  Future<void> sendFriendAcceptedNotification({
    required int targetUserId,
    required String senderName,
  }) async {
    if (!isConnected) return;
    try {
      await hubConnection.invoke('SendMessage', args: [
        {
          'conversationId': 0,
          'receiverId': targetUserId,
          'receiverName': senderName,
          'content': '$senderName đã đồng ý kết bạn',
          'type': 'FriendAccepted',
        }
      ]);
      debugPrint('🤝 [SignalR]: Đã gửi thông báo đồng ý kết bạn tới user $targetUserId');
    } catch (_) {}
  }

  /// Gửi tin nhắn realtime
  Future<void> sendMessage({
    required int conversationId,
    required String content,
    String? receiverName,
    int? receiverId,
  }) async {
    if (!isConnected) {
      debugPrint('⚠️ [SignalR]: Chưa kết nối tới server, đang thử khởi động lại...');
      try {
        await hubConnection.start();
      } catch (_) {}
    }

    await hubConnection.invoke('SendMessage', args: [
      {
        'conversationId': conversationId,
        'content': content,
        'receiverName': receiverName,
        'receiverId': receiverId,
        'contactName': receiverName,
        'type': 'Text',
      }
    ]);
  }

  /// Báo đang soạn tin nhắn
  Future<void> sendTyping(int conversationId, bool isTyping) async {
    if (!isConnected) return;
    try {
      await hubConnection.invoke('SendTyping', args: [conversationId, isTyping]);
    } catch (e) {
      debugPrint('⚠️ [SignalR]: Lỗi khi gửi sự kiện typing: $e');
    }
  }

  /// Đóng kết nối SignalR
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop().timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            debugPrint('⚠️ [SignalR]: Ngắt kết nối timeout.');
          },
        );
        debugPrint('🛑 [SignalR]: Đã ngắt kết nối thành công.');
      } catch (e) {
        debugPrint('⚠️ [SignalR]: Lỗi khi ngắt kết nối: $e');
      } finally {
        _notifyStateChanged(HubConnectionState.Disconnected);
      }
    }
  }

  void _notifyStateChanged(HubConnectionState state) {
    _connectionStateController.add(state);
    onConnectionStateChanged?.call(state);
  }

  /// Hủy các StreamController khi không sử dụng
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _onlineStatusController.close();
    _friendRequestController.close();
    _connectionStateController.close();
  }
}

/// Alias ChatSignalRService để tương thích với mọi cách gọi tên trong tài liệu
typedef ChatSignalRService = SignalRService;
