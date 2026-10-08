import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/usecases/send_reset_code_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendResetCodeUseCase sendResetCodeUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordBloc({
    required this.sendResetCodeUseCase,
    VerifyOtpUseCase? verifyOtpUseCase,
    ResendOtpUseCase? resendOtpUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
  })  : verifyOtpUseCase = verifyOtpUseCase ??
            VerifyOtpUseCase(repository: sendResetCodeUseCase.repository),
        resendOtpUseCase = resendOtpUseCase ??
            ResendOtpUseCase(repository: sendResetCodeUseCase.repository),
        resetPasswordUseCase = resetPasswordUseCase ??
            ResetPasswordUseCase(repository: sendResetCodeUseCase.repository),
        super(const ForgotPasswordInitial()) {
    on<SendResetCodeRequested>(_onSendResetCodeRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ForgotPasswordResetToInitial>(_onResetToInitial);
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

    emit(const ForgotPasswordLoading('Đang gửi mã xác nhận...'));
    try {
      final msg = await sendResetCodeUseCase(input);
      debugPrint('📧 [ForgotPasswordBloc]: Gửi mã OTP thành công tới $input: $msg');
      emit(ForgotPasswordCodeSent(input, message: msg));
    } catch (e) {
      final errorMsg = _cleanErrorMessage(e);
      debugPrint('🚨 [ForgotPasswordBloc]: Gửi mã OTP thất bại: $errorMsg');
      emit(ForgotPasswordFailure(errorMsg));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final otp = event.otp.trim();
    if (otp.length != 6) {
      emit(const ForgotPasswordFailure('Mã OTP phải gồm 6 chữ số.'));
      return;
    }

    emit(const ForgotPasswordLoading('Đang kiểm tra mã OTP...'));
    try {
      final msg = await verifyOtpUseCase(
        email: event.email.trim(),
        otp: otp,
      );
      debugPrint('✅ [ForgotPasswordBloc]: Xác thực OTP thành công: $msg');
      emit(ForgotPasswordOtpVerified(
        email: event.email.trim(),
        otp: otp,
        message: msg,
      ));
    } catch (e) {
      final errorMsg = _cleanErrorMessage(e);
      debugPrint('❌ [ForgotPasswordBloc]: Xác thực OTP thất bại: $errorMsg');
      emit(ForgotPasswordFailure(errorMsg));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading('Đang gửi lại mã OTP...'));
    try {
      final msg = await resendOtpUseCase(event.email.trim());
      debugPrint('🔄 [ForgotPasswordBloc]: Gửi lại OTP thành công: $msg');
      emit(ForgotPasswordResendOtpSuccess(
        message: msg,
        cooldownSeconds: 60,
      ));
    } catch (e) {
      final errorMsg = _cleanErrorMessage(e);
      debugPrint('⚠️ [ForgotPasswordBloc]: Gửi lại OTP thất bại: $errorMsg');
      emit(ForgotPasswordFailure(errorMsg));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final lang = LocaleController.instance;
    final newPassword = event.newPassword.trim();
    final confirmPassword = event.confirmPassword?.trim() ?? newPassword;

    if (newPassword.length < 6) {
      emit(ForgotPasswordFailure(lang.passwordMinLength));
      return;
    }

    if (newPassword != confirmPassword) {
      emit(ForgotPasswordFailure(lang.passwordNotMatch));
      return;
    }

    emit(const ForgotPasswordLoading('Đang đặt lại mật khẩu mới...'));
    try {
      final msg = await resetPasswordUseCase(
        email: event.email.trim(),
        otp: event.otp.trim(),
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      debugPrint('🎉 [ForgotPasswordBloc]: Đặt lại mật khẩu thành công: $msg');
      emit(ForgotPasswordResetSuccess(message: msg));
    } catch (e) {
      final errorMsg = _cleanErrorMessage(e);
      debugPrint('🚨 [ForgotPasswordBloc]: Đặt lại mật khẩu thất bại: $errorMsg');
      emit(ForgotPasswordFailure(errorMsg));
    }
  }

  void _onResetToInitial(
    ForgotPasswordResetToInitial event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(const ForgotPasswordInitial());
  }

  String _cleanErrorMessage(dynamic e) {
    var msg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
    return msg.trim().isNotEmpty ? msg : 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
  }
}
