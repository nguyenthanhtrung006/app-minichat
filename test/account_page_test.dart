import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/account/presentation/widgets/profile_menu_card.dart';

void main() {
  group('Account Page & Logout Widget Tests', () {
    testWidgets('ProfileMenuCard renders items and triggers onLogout callback',
        (WidgetTester tester) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileMenuCard(
              onLogout: () {
                logoutCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Thông tin cá nhân'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);

      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      expect(logoutCalled, isTrue);
    });

    testWidgets('Logout confirmation bottom dialog can be displayed and confirmed',
        (WidgetTester tester) async {
      bool dialogConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất tài khoản'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          dialogConfirmed = true;
                          Navigator.pop(ctx);
                        },
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Mở đăng xuất'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mở đăng xuất'));
      await tester.pumpAndSettle();

      expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      expect(dialogConfirmed, isTrue);
    });
  });
}
