import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_social_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithSocialUseCase loginWithSocialUseCase;

  LoginBloc({
    required this.loginWithEmailUseCase,
    required this.loginWithSocialUseCase,
  }) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithSocialRequested>(_onLoginWithSocialRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final lang = LocaleController.instance;

    if (event.emailOrPhone.trim().isEmpty) {
      emit(LoginFailure(lang.enterEmailOrPhone));
      return;
    }
    if (event.password.trim().isEmpty) {
      emit(LoginFailure(lang.enterPassword));
      return;
    }

    emit(const LoginLoading());
    try {
      final user = await loginWithEmailUseCase(
        emailOrPhone: event.emailOrPhone.trim(),
        password: event.password,
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginWithSocialRequested(
    LoginWithSocialRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final user = await loginWithSocialUseCase(event.provider);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
