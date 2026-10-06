import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/Forgotpassword/forgot_password_page.dart';
import 'package:minichatapp/Feature/Forgotpassword/presentation/widgets/forgot_password_header_icon.dart';
import 'package:minichatapp/Feature/Login/login_page.dart';
import 'package:minichatapp/Feature/Login/presentation/widgets/custom_text_field.dart';
import 'package:minichatapp/Feature/Login/presentation/widgets/social_login_button.dart';
import 'package:minichatapp/Feature/Register/register_page.dart';

void main() {
  group('Login, Register, and Forgotpassword Feature Tests', () {
    testWidgets('LoginPage renders logo, input fields, and social buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.pumpAndSettle();

      expect(find.text('Mini Chat'), findsOneWidget);
      expect(find.text('Kết nối mọi khoảnh khắc 💙'), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.byType(SocialLoginButton), findsNWidgets(2));
      expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
      expect(find.text('Đăng nhập bằng Facebook'), findsOneWidget);
      expect(find.text('Chưa có tài khoản? '), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
    });

    testWidgets('RegisterPage renders all 4 input fields and CTA button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      expect(find.text('Đăng ký tài khoản'), findsOneWidget);
      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Số điện thoại / Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('Đã có tài khoản? '), findsOneWidget);
    });

    testWidgets('ForgotPasswordPage renders hero mail icon, input, and CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
      await tester.pumpAndSettle();

      expect(find.text('Quên mật khẩu'), findsOneWidget);
      expect(find.byType(ForgotPasswordHeaderIcon), findsOneWidget);
      expect(
        find.text(
          'Nhập email hoặc số điện thoại\ncủa bạn, chúng tôi sẽ gửi mã xác nhận.',
        ),
        findsOneWidget,
      );
      expect(find.text('Email hoặc số điện thoại'), findsOneWidget);
      expect(find.text('Gửi mã'), findsOneWidget);
      expect(find.text('Quay lại đăng nhập'), findsOneWidget);
    });
  });
}
