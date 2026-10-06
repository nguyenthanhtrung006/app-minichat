import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/usecases/send_reset_code_usecase.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendResetCodeUseCase sendResetCodeUseCase;

  ForgotPasswordBloc({required this.sendResetCodeUseCase})
      : super(const ForgotPasswordInitial()) {
    on<SendResetCodeRequested>(_onSendResetCodeRequested);
  }

  Future<void> _onSendResetCodeRequested(
    SendResetCodeRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final lang = LocaleController.instance;
    final input = event.emailOrPhone.trim();
    if (input.isEmpty) {
      emit(ForgotPasswordFailure(lang.enterEmailOrPhone));
      return;
    }

    emit(const ForgotPasswordLoading());
    try {
      await sendResetCodeUseCase(input);
      emit(ForgotPasswordCodeSent(input));
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
