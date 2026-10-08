import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/common/widgets/app_bottom_dialog.dart';

void main() {
  group('AppBottomDialog Reusable Widget Tests', () {
    testWidgets('AppBottomDialog renders success type with title and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppBottomDialog.showSuccess(
                  context: context,
                  title: 'Đăng ký tài khoản thành công!',
                  message: 'Tài khoản của bạn đã được tạo thành công.',
                  primaryButtonText: 'Đăng nhập ngay',
                );
              },
              child: const Text('Mở dialog'),
            ),
          ),
        ),
      );

      // Tap to open bottom sheet dialog
      await tester.tap(find.text('Mở dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Đăng ký tài khoản thành công!'), findsOneWidget);
      expect(find.text('Tài khoản của bạn đã được tạo thành công.'), findsOneWidget);
      expect(find.text('Đăng nhập ngay'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Tap button to close
      await tester.tap(find.text('Đăng nhập ngay'));
      await tester.pumpAndSettle();

      expect(find.text('Đăng ký tài khoản thành công!'), findsNothing);
    });

    testWidgets('AppBottomDialog renders error type with primary and secondary buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppBottomDialog.showError(
                  context: context,
                  title: 'Đã có lỗi xảy ra',
                  message: 'Không thể kết nối máy chủ',
                  primaryButtonText: 'Thử lại',
                  secondaryButtonText: 'Hủy bỏ',
                );
              },
              child: const Text('Mở dialog lỗi'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mở dialog lỗi'));
      await tester.pumpAndSettle();

      expect(find.text('Đã có lỗi xảy ra'), findsOneWidget);
      expect(find.text('Không thể kết nối máy chủ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.text('Hủy bỏ'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

      await tester.tap(find.text('Hủy bỏ'));
      await tester.pumpAndSettle();

      expect(find.text('Đã có lỗi xảy ra'), findsNothing);
    });
  });
}
