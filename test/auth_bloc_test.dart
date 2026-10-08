import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/Forgotpassword/domain/repositories/forgot_password_repository.dart';
import 'package:minichatapp/Feature/Forgotpassword/domain/usecases/send_reset_code_usecase.dart';
import 'package:minichatapp/Feature/Forgotpassword/presentation/bloc/forgot_password_bloc.dart';
import 'package:minichatapp/Feature/Forgotpassword/presentation/bloc/forgot_password_event.dart';
import 'package:minichatapp/Feature/Forgotpassword/presentation/bloc/forgot_password_state.dart';
import 'package:minichatapp/Feature/Login/domain/entities/user_entity.dart';
import 'package:minichatapp/Feature/Login/domain/repositories/login_repository.dart';
import 'package:minichatapp/Feature/Login/domain/usecases/login_with_email_usecase.dart';
import 'package:minichatapp/Feature/Login/domain/usecases/login_with_social_usecase.dart';
import 'package:minichatapp/Feature/Login/presentation/bloc/login_bloc.dart';
import 'package:minichatapp/Feature/Login/presentation/bloc/login_event.dart';
import 'package:minichatapp/Feature/Login/presentation/bloc/login_state.dart';
import 'package:minichatapp/Feature/Register/domain/entities/register_params.dart';
import 'package:minichatapp/Feature/Register/domain/repositories/register_repository.dart';
import 'package:minichatapp/Feature/Register/domain/usecases/register_usecase.dart';
import 'package:minichatapp/Feature/Register/presentation/bloc/register_bloc.dart';
import 'package:minichatapp/Feature/Register/presentation/bloc/register_event.dart';
import 'package:minichatapp/Feature/Register/presentation/bloc/register_state.dart';

class MockLoginRepository implements LoginRepository {
  @override
  Future<UserEntity> loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) async {
    return UserEntity(
      id: 1,
      email: emailOrPhone,
      fullName: 'Test User',
    );
  }

  @override
  Future<UserEntity> loginWithSocial(SocialProvider provider) async {
    return const UserEntity(
      id: 2,
      email: 'user@social.com',
      fullName: 'Social User',
    );
  }
}

class MockRegisterRepository implements RegisterRepository {
  @override
  Future<bool> register(RegisterParams params) async => true;
}

class MockForgotPasswordRepository implements ForgotPasswordRepository {
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
  group('Auth BLoC Unit Tests', () {
    test('LoginBloc emits LoginSuccess on valid credentials', () async {
      final repo = MockLoginRepository();
      final bloc = LoginBloc(
        loginWithEmailUseCase: LoginWithEmailUseCase(repository: repo),
        loginWithSocialUseCase: LoginWithSocialUseCase(repository: repo),
      );

      bloc.add(const LoginSubmitted(
        emailOrPhone: 'test@example.com',
        password: 'password123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const LoginLoading(),
          isA<LoginSuccess>().having(
            (s) => s.user.emailOrPhone,
            'email',
            'test@example.com',
          ),
        ]),
      );
      bloc.close();
    });

    test('RegisterBloc emits RegisterSuccess on valid matching passwords', () async {
      final repo = MockRegisterRepository();
      final bloc = RegisterBloc(
        registerUseCase: RegisterUseCase(repository: repo),
      );

      bloc.add(const RegisterSubmitted(
        RegisterParams(
          fullName: 'Nguyen Van A',
          emailOrPhone: 'a@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        ),
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const RegisterLoading(),
          const RegisterSuccess(),
        ]),
      );
      bloc.close();
    });

    test('ForgotPasswordBloc emits ForgotPasswordCodeSent on non-empty email', () async {
      final repo = MockForgotPasswordRepository();
      final bloc = ForgotPasswordBloc(
        sendResetCodeUseCase: SendResetCodeUseCase(repository: repo),
      );

      bloc.add(const SendResetCodeRequested('test@example.com'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ForgotPasswordLoading('Đang gửi mã xác nhận...'),
          const ForgotPasswordCodeSent('test@example.com',
              message: 'Đã gửi mã xác nhận đến test@example.com'),
        ]),
      );
      bloc.close();
    });

    test('ForgotPasswordBloc emits ForgotPasswordOtpVerified on valid OTP', () async {
      final repo = MockForgotPasswordRepository();
      final bloc = ForgotPasswordBloc(
        sendResetCodeUseCase: SendResetCodeUseCase(repository: repo),
      );

      bloc.add(const VerifyOtpRequested(
        email: 'test@example.com',
        otp: '123456',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ForgotPasswordLoading('Đang kiểm tra mã OTP...'),
          const ForgotPasswordOtpVerified(
            email: 'test@example.com',
            otp: '123456',
            message: 'Xác thực OTP thành công.',
          ),
        ]),
      );
      bloc.close();
    });

    test('ForgotPasswordBloc emits ForgotPasswordFailure on invalid OTP', () async {
      final repo = MockForgotPasswordRepository();
      final bloc = ForgotPasswordBloc(
        sendResetCodeUseCase: SendResetCodeUseCase(repository: repo),
      );

      bloc.add(const VerifyOtpRequested(
        email: 'test@example.com',
        otp: '999999',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ForgotPasswordLoading('Đang kiểm tra mã OTP...'),
          const ForgotPasswordFailure('Mã OTP không chính xác.'),
        ]),
      );
      bloc.close();
    });

    test('ForgotPasswordBloc emits ForgotPasswordResendOtpSuccess on resend OTP', () async {
      final repo = MockForgotPasswordRepository();
      final bloc = ForgotPasswordBloc(
        sendResetCodeUseCase: SendResetCodeUseCase(repository: repo),
      );

      bloc.add(const ResendOtpRequested('test@example.com'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ForgotPasswordLoading('Đang gửi lại mã OTP...'),
          const ForgotPasswordResendOtpSuccess(
            message:
                'Mã xác thực OTP đã được gửi về email của bạn. Vui lòng kiểm tra hộp thư!',
            cooldownSeconds: 60,
          ),
        ]),
      );
      bloc.close();
    });

    test('ForgotPasswordBloc emits ForgotPasswordResetSuccess on reset password', () async {
      final repo = MockForgotPasswordRepository();
      final bloc = ForgotPasswordBloc(
        sendResetCodeUseCase: SendResetCodeUseCase(repository: repo),
      );

      bloc.add(const ResetPasswordRequested(
        email: 'test@example.com',
        otp: '123456',
        newPassword: 'newpassword123',
        confirmPassword: 'newpassword123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ForgotPasswordLoading('Đang đặt lại mật khẩu mới...'),
          const ForgotPasswordResetSuccess(
            message: 'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.',
          ),
        ]),
      );
      bloc.close();
    });
  });
}
