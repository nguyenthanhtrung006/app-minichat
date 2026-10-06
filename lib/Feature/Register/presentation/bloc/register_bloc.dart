import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterBloc({required this.registerUseCase})
      : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final lang = LocaleController.instance;
    final p = event.params;

    if (p.fullName.trim().isEmpty) {
      emit(RegisterFailure(lang.enterFullName));
      return;
    }
    if (p.emailOrPhone.trim().isEmpty) {
      emit(RegisterFailure(lang.enterEmailOrPhone));
      return;
    }
    if (p.password.trim().isEmpty) {
      emit(RegisterFailure(lang.enterPassword));
      return;
    }
    if (p.password.length < 6) {
      emit(RegisterFailure(lang.passwordMinLength));
      return;
    }
    if (p.password != p.confirmPassword) {
      emit(RegisterFailure(lang.passwordNotMatch));
      return;
    }

    emit(const RegisterLoading());
    try {
      await registerUseCase(p);
      emit(const RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
