import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  final String? loadingMessage;
  const ForgotPasswordLoading([this.loadingMessage]);

  @override
  List<Object?> get props => [loadingMessage];
}

class ForgotPasswordCodeSent extends ForgotPasswordState {
  final String emailOrPhone;
  final String message;

  const ForgotPasswordCodeSent(this.emailOrPhone, {this.message = ''});

  @override
  List<Object?> get props => [emailOrPhone, message];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  final String otp;
  final String message;

  const ForgotPasswordOtpVerified({
    required this.email,
    required this.otp,
    this.message = 'Xác thực OTP thành công.',
  });

  @override
  List<Object?> get props => [email, otp, message];
}

class ForgotPasswordResendOtpSuccess extends ForgotPasswordState {
  final String message;
  final int cooldownSeconds;

  const ForgotPasswordResendOtpSuccess({
    required this.message,
    this.cooldownSeconds = 60,
  });

  @override
  List<Object?> get props => [message, cooldownSeconds];
}

class ForgotPasswordResetSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordResetSuccess({
    this.message = 'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.',
  });

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;

  const ForgotPasswordFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
