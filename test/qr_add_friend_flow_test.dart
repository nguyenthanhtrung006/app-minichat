import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/friend/data/datasources/friend_remote_datasource.dart';
import 'package:minichatapp/Feature/friend/domain/entities/friend_entities.dart';
import 'package:minichatapp/Feature/friend/presentation/pages/friend_page.dart';
import 'package:minichatapp/Feature/qr/data/models/qr_code_model.dart';
import 'package:minichatapp/Feature/qr/domain/entities/qr_code_entity.dart';
import 'package:minichatapp/Feature/qr/presentation/widgets/qr_result_bottom_sheet.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('vi'),
    home: child,
  );
}

void main() {
  group('QR Friend Adding Flow Tests', () {
    test('QrCodeModel parses rich QR links and JSON correctly', () {
      // 1. Minichat add link with name query param
      final model1 = QrCodeModel.fromRawString(
        'minichat://add/friend_01?name=Ho%C3%A0ng%20Gia%20B%E1%BA%A3o&phone=0912345678',
      );
      expect(model1.type, equals(QrCodeType.userProfile));
      expect(model1.title, equals('Hoàng Gia Bảo'));
      expect(model1.actionPayload, equals('friend_01'));
      expect(model1.subtitle, contains('0912345678'));

      // 2. JSON QR code
      final model2 = QrCodeModel.fromRawString(
        '{"fullName": "Lê Thị Thảo", "id": "user_99", "phone": "0988776655"}',
      );
      expect(model2.type, equals(QrCodeType.userProfile));
      expect(model2.title, equals('Lê Thị Thảo'));
      expect(model2.actionPayload, equals('user_99'));

      // 3. Simple hex code
      final model3 = QrCodeModel.fromRawString('minichat://add/8f7a91a2b3c4');
      expect(model3.type, equals(QrCodeType.userProfile));
      expect(model3.actionPayload, equals('8f7a91a2b3c4'));
    });

    testWidgets('Tapping Add Friend in QrResultBottomSheet adds friend to datasource',
        (WidgetTester tester) async {
      final qrEntity = QrCodeEntity(
        rawValue: 'minichat://add/u_888',
        type: QrCodeType.userProfile,
        title: 'Trần Quang Hải',
        subtitle: 'ID: u_888',
        actionPayload: 'u_888',
        avatarUrl: null,
        scannedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        _buildTestApp(
          Scaffold(
            body: QrResultBottomSheet(
              data: qrEntity,
              onScanAgain: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify QR dialog shows friend name
      expect(find.text('Trần Quang Hải'), findsOneWidget);

      // Tap "Kết bạn"
      final addFriendBtn = find.text('Kết bạn');
      expect(addFriendBtn, findsOneWidget);
      await tester.tap(addFriendBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify friend was added to FriendRemoteDataSourceImpl
      final friends = await FriendRemoteDataSourceImpl.instance.getFriends();
      expect(
        friends.any((f) => f.name == 'Trần Quang Hải'),
        isTrue,
      );

      // Verify friend request was recorded
      final requests =
          await FriendRemoteDataSourceImpl.instance.getFriendRequests();
      expect(
        requests.any((r) => r.name == 'Trần Quang Hải'),
        isTrue,
      );
    });

    testWidgets('FriendPage displays newly added friend after addition',
        (WidgetTester tester) async {
      // Add a test friend
      await FriendRemoteDataSourceImpl.instance.addFriend(
        const FriendItem(
          id: 'u_test_999',
          name: 'Vũ Đức Đam',
          status: 'Đang hoạt động',
          isOnline: true,
        ),
      );

      await tester.pumpWidget(_buildTestApp(const FriendPage()));
      await tester.pumpAndSettle();

      // Verify friend name is now visible on FriendPage
      expect(find.text('Vũ Đức Đam'), findsOneWidget);
      expect(find.text('Chưa có bạn bè nào'), findsNothing);
    });
  });
}
