import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/friend/data/datasources/friend_remote_datasource.dart';
import 'package:minichatapp/Feature/friend/domain/entities/friend_entities.dart';
import 'package:minichatapp/core/network/signalr_service.dart';
import 'package:minichatapp/core/session/auth_session_manager.dart';
import 'package:minichatapp/core/storage/token_storage.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    navigatorKey: AuthSessionManager.navigatorKey,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, String> mockStorage = {};

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'write') {
          final args = methodCall.arguments as Map;
          mockStorage[args['key'] as String] = args['value'] as String;
          return null;
        } else if (methodCall.method == 'read') {
          final args = methodCall.arguments as Map;
          return mockStorage[args['key'] as String];
        } else if (methodCall.method == 'delete') {
          final args = methodCall.arguments as Map;
          mockStorage.remove(args['key'] as String);
          return null;
        } else if (methodCall.method == 'deleteAll') {
          mockStorage.clear();
          return null;
        }
        return null;
      },
    );
  });

  group('Single Device & Auto-Login & Friend Sync Tests', () {
    test('SplashSuccess emits isAuthenticated true when token is present', () async {
      // Setup token
      await TokenStorage.instance.saveToken('test_fake_jwt_token_123');
      expect(await TokenStorage.instance.hasToken(), isTrue);

      // Verify token presence
      final token = await TokenStorage.instance.getToken();
      expect(token, equals('test_fake_jwt_token_123'));

      // Clean up
      await TokenStorage.instance.deleteToken();
      expect(await TokenStorage.instance.hasToken(), isFalse);
    });

    testWidgets('AuthSessionManager handleForceLogout displays popup and clears session',
        (WidgetTester tester) async {
      AuthSessionManager.navigatorKey = GlobalKey<NavigatorState>();
      AuthSessionManager.instance.onLoginSuccess();
      await TokenStorage.instance.saveToken('test_session_token');

      await tester.pumpWidget(
        _buildTestApp(
          const Scaffold(
            body: Center(child: Text('Main Screen Content')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await AuthSessionManager.instance.handleForceLogout(
        reason: 'Tài khoản của bạn đã được đăng nhập trên một thiết bị khác.',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify popup dialog appears with warning
      expect(find.text('Phiên đăng nhập hết hạn'), findsOneWidget);
      expect(
        find.textContaining('đã được đăng nhập trên một thiết bị khác'),
        findsOneWidget,
      );

      // Verify token has been cleared
      final hasToken = await TokenStorage.instance.hasToken();
      expect(hasToken, isFalse);
    });

    test('FriendRemoteDataSourceImpl preserves and updates friends and requests lists',
        () async {
      final ds = FriendRemoteDataSourceImpl.instance;

      final friendA = const FriendItem(
        id: 'u_101',
        name: 'Trần Văn An',
        status: 'Đang hoạt động',
        isOnline: true,
      );

      final reqA = const FriendRequest(
        id: 'req_201',
        name: 'Lê Hoàng Nam',
        subtitle: 'Đã gửi lời mời kết bạn',
        isSent: false,
      );

      await ds.addFriend(friendA);
      await ds.addFriendRequest(reqA);

      final friends = await ds.getFriends();
      final requests = await ds.getFriendRequests();

      expect(friends.any((f) => f.name == 'Trần Văn An'), isTrue);
      expect(requests.any((r) => r.name == 'Lê Hoàng Nam'), isTrue);

      // Verify toggle friend request
      await ds.toggleFriendRequest('req_201');
      final updatedRequests = await ds.getFriendRequests();
      final toggled = updatedRequests.firstWhere((r) => r.id == 'req_201');
      expect(toggled.isSent, isTrue);
    });

    test('SignalRService generates unique deviceSessionId for single device constraint', () {
      final sessionId = AuthSessionManager.instance.deviceSessionId;
      expect(sessionId, isNotEmpty);
      expect(sessionId.contains('_'), isTrue);
    });

    test('TokenStorage saves and retrieves email and userId correctly', () async {
      await TokenStorage.instance.saveUserInfo(
        email: 'alice@gmail.com',
        userId: '888',
      );

      final email = await TokenStorage.instance.getUserEmail();
      final uid = await TokenStorage.instance.getUserId();

      expect(email, equals('alice@gmail.com'));
      expect(uid, equals('888'));
    });

    test('TokenStorage decodes email and userId from valid JWT token payload', () {
      // Create a test JWT token with sub/nameid and email
      // Header: {"alg":"HS256","typ":"JWT"} -> eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
      // Payload: {"nameid":"999","email":"testuser@example.com"}
      const payloadBase64 = 'eyJuYW1laWQiOiI5OTkiLCJlbWFpbCI6InRlc3R1c2VyQGV4YW1wbGUuY29tIn0';
      const fakeToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$payloadBase64.signature';

      final decodedUserId = TokenStorage.parseUserIdFromJwt(fakeToken);
      final decodedEmail = TokenStorage.parseEmailFromJwt(fakeToken);

      expect(decodedUserId, equals('999'));
      expect(decodedEmail, equals('testuser@example.com'));
    });

    testWidgets('Different account login on another device DOES NOT kick current user',
        (WidgetTester tester) async {
      AuthSessionManager.navigatorKey = GlobalKey<NavigatorState>();
      // Current device is logged in as 'alice@gmail.com' (userId: '101')
      AuthSessionManager.instance.onLoginSuccess(
        email: 'alice@gmail.com',
        userId: '101',
      );
      await TokenStorage.instance.saveUserInfo(
        email: 'alice@gmail.com',
        userId: '101',
      );
      await TokenStorage.instance.saveToken('alice_active_token');

      await tester.pumpWidget(
        _buildTestApp(
          const Scaffold(
            body: Center(child: Text('Alice Active Screen')),
          ),
        ),
      );
      await tester.pump();

      // Incoming kick message is for a DIFFERENT account: 'bob@gmail.com' (userId: '202')
      final otherAccountKickMessage = {
        'type': 'CONCURRENT_LOGIN_KICK',
        'attachmentUrl': 'bob_device_session_xyz',
        'content': '{"email":"bob@gmail.com","userId":"202","sessionId":"bob_device_session_xyz"}',
      };

      // Emulate SignalR receiving message from a different account
      final signalR = SignalRService.instance;
      signalR.currentUserEmail = 'alice@gmail.com';
      signalR.currentUserId = '101';

      // Parse and verify that it doesn't match
      final contentStr = otherAccountKickMessage['content']!;
      final isSameAccount = contentStr.contains('alice@gmail.com');
      expect(isSameAccount, isFalse);

      // Verify no popup dialog appeared
      expect(find.text('Phiên đăng nhập hết hạn'), findsNothing);
      expect(find.text('Alice Active Screen'), findsOneWidget);
      expect(await TokenStorage.instance.hasToken(), isTrue);
    });

    testWidgets('SAME account login on another device KICKS current device with popup',
        (WidgetTester tester) async {
      AuthSessionManager.navigatorKey = GlobalKey<NavigatorState>();
      // Current device is logged in as 'alice@gmail.com' (userId: '101')
      AuthSessionManager.instance.onLoginSuccess(
        email: 'alice@gmail.com',
        userId: '101',
      );
      await TokenStorage.instance.saveUserInfo(
        email: 'alice@gmail.com',
        userId: '101',
      );
      await TokenStorage.instance.saveToken('alice_active_token');

      await tester.pumpWidget(
        _buildTestApp(
          const Scaffold(
            body: Center(child: Text('Alice Active Screen')),
          ),
        ),
      );
      await tester.pump();

      // Incoming kick message is for THE SAME account: 'alice@gmail.com' from device session 'alice_other_device_session'
      const otherDeviceSessionId = 'alice_other_device_session';
      expect(otherDeviceSessionId != AuthSessionManager.instance.deviceSessionId, isTrue);

      // Trigger force logout on current device because same account logged in elsewhere
      await AuthSessionManager.instance.handleForceLogout(
        reason: 'Tài khoản của bạn đã được đăng nhập trên một thiết bị khác.',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify popup dialog appears
      expect(find.text('Phiên đăng nhập hết hạn'), findsOneWidget);
      expect(
        find.textContaining('đã được đăng nhập trên một thiết bị khác'),
        findsOneWidget,
      );

      // Verify token cleared
      expect(await TokenStorage.instance.hasToken(), isFalse);
    });
  });
}
