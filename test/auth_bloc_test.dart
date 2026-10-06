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
    return UserEntity(id: 'test_1', emailOrPhone: emailOrPhone);
  }

  @override
  Future<UserEntity> loginWithSocial(SocialProvider provider) async {
    return const UserEntity(id: 'social_1', emailOrPhone: 'user@social.com');
  }
}

class MockRegisterRepository implements RegisterRepository {
  @override
  Future<bool> register(RegisterParams params) async => true;
}

class MockForgotPasswordRepository implements ForgotPasswordRepository {
  @override
  Future<bool> sendResetCode(String emailOrPhone) async => true;
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
          const ForgotPasswordLoading(),
          const ForgotPasswordCodeSent('test@example.com'),
        ]),
      );
      bloc.close();
    });
  });
}
