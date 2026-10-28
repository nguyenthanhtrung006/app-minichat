import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/call/presentation/pages/call_page.dart';
import 'package:minichatapp/Feature/call/data/datasources/call_remote_datasource.dart';
import 'package:minichatapp/Feature/call/domain/entities/call_item.dart';
import 'package:minichatapp/Feature/chat/presentation/pages/chat_page.dart';
import 'package:minichatapp/Feature/friend/presentation/pages/friend_page.dart';
import 'package:minichatapp/Feature/sendthedetails/presentation/pages/send_the_details_page.dart';
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

class _MockEmptyCallRemoteDataSource implements CallRemoteDataSource {
  @override
  Future<List<CallItem>> getCallHistory({int page = 1, int pageSize = 30}) async => [];

  @override
  Future<bool> deleteCallHistory(int id) async => true;
}

void main() {
  group('Empty State and Dynamic Clean Data Tests', () {
    testWidgets('ChatPage shows empty state and scan QR button when chats list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const ChatPage()));
      await tester.pumpAndSettle();

      // Verify no hardcoded mock chat names
      expect(find.text('Nguyễn Văn Nam'), findsNothing);
      expect(find.text('Phạm Thị Mai'), findsNothing);

      // Verify empty state messages
      expect(find.text('Chưa có cuộc trò chuyện nào'), findsOneWidget);
      expect(find.text('Quét mã QR kết bạn'), findsOneWidget);
    });

    testWidgets('FriendPage shows empty state and no hardcoded friends',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(const FriendPage()));
      await tester.pumpAndSettle();

      // Verify no hardcoded friends
      expect(find.text('Nguyễn Văn Nam'), findsNothing);
      expect(find.text('Trần Đức Huy'), findsNothing);

      // Verify empty state
      expect(find.text('Chưa có bạn bè nào'), findsOneWidget);
    });

    testWidgets('CallPage shows empty state and no hardcoded call history',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(CallPage(remoteDataSource: _MockEmptyCallRemoteDataSource())));
      await tester.pumpAndSettle();

      // Verify no hardcoded call records
      expect(find.text('Nguyễn Văn Nam'), findsNothing);
      expect(find.text('Chưa có lịch sử cuộc gọi'), findsOneWidget);
      expect(
        find.text('Các cuộc gọi thoại và video sẽ xuất hiện tại đây'),
        findsOneWidget,
      );
    });

    testWidgets('SendTheDetailsPage shows empty chat placeholder without hardcoded messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const SendTheDetailsPage(
            contactName: 'Người bạn mới',
            isOnline: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify contact name in header
      expect(find.text('Người bạn mới'), findsOneWidget);

      // Verify no old hardcoded mock messages
      expect(find.text('Chào bạn, hôm nay thế nào?'), findsNothing);
      expect(find.text('Mình khỏe, cảm ơn bạn nhé!'), findsNothing);

      // Verify empty state placeholder
      expect(find.text('Bắt đầu cuộc trò chuyện'), findsOneWidget);
      expect(
        find.text('Gửi tin nhắn đầu tiên cho Người bạn mới để bắt đầu trò chuyện realtime!'),
        findsOneWidget,
      );
    });
  });
}
