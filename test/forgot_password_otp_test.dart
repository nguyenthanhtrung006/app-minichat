import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/Forgotpassword/domain/repositories/forgot_password_repository.dart';
import 'package:minichatapp/Feature/Forgotpassword/forgot_password_page.dart';
import 'package:minichatapp/Feature/Forgotpassword/presentation/widgets/otp_input_field.dart';

class TestMockForgotPasswordRepository implements ForgotPasswordRepository {
  @override
  Future<String> sendResetCode(String emailOrPhone) async =>
      'Đã gửi mã xác nhận đến $emailOrPhone';

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    if (otp == '123456') {
      return 'Xác thực OTP thành công.';
    }
    throw Exception('Mã OTP không chính xác.');
  }

  @override
  Future<String> resendOtp(String email) async =>
      'Mã xác thực OTP đã được gửi về email của bạn. Vui lòng kiểm tra hộp thư!';

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    String? confirmPassword,
  }) async =>
      'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.';
}

void main() {
  group('ForgotPassword & OTP Verification UI Flow Tests', () {
    testWidgets(
        'ForgotPassword full UI navigation through OTP and Reset Password',
        (WidgetTester tester) async {
      final mockRepo = TestMockForgotPasswordRepository();

      await tester.pumpWidget(MaterialApp(
        home: ForgotPasswordPage(repository: mockRepo),
      ));
      await tester.pumpAndSettle();

      // Step 0: Check initial email screen
      expect(find.text('Quên mật khẩu'), findsOneWidget);
      expect(find.text('Nhập email'), findsOneWidget);
      expect(find.text('Mã OTP'), findsOneWidget);
      expect(find.text('Mật khẩu mới'), findsOneWidget);
      expect(find.text('Gửi mã'), findsOneWidget);

      // Enter valid email
      await tester.enterText(
          find.byType(TextField).first, 'user@gmail.com');
      await tester.tap(find.text('Gửi mã'));
      await tester.pumpAndSettle();

      // Dismiss any transient snackbar
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Step 1: Should now be in OTP verification screen
      expect(find.text('Xác thực OTP'), findsOneWidget);
      expect(find.text('Nhập mã xác thực'), findsOneWidget);
      expect(find.byType(OtpInputField), findsOneWidget);
      expect(find.text('Đổi email khác'), findsOneWidget);
      expect(find.text('Xác nhận mã OTP'), findsOneWidget);

      // Verify cooldown text
      expect(find.textContaining('Chưa nhận được mã?'), findsOneWidget);

      // Enter valid OTP '123456' -> triggers completion and transitions to Step 2
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pumpAndSettle();

      // Step 2: Should now be in New Password screen
      expect(find.text('Đặt lại mật khẩu'), findsOneWidget);
      expect(find.text('Tạo mật khẩu mới'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);

      // Enter new password and confirm
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'newpassword123');
      await tester.enterText(textFields.at(1), 'newpassword123');

      // Scroll to button to ensure it's not obscured
      await tester.ensureVisible(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      // Should show AppBottomDialog with success
      expect(find.text('Đặt lại mật khẩu thành công!'), findsOneWidget);
      expect(find.text('Đăng nhập ngay'), findsOneWidget);
    });
  });
}
