import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi mã xác nhận OTP qua email
class SendResetCodeRequested extends ForgotPasswordEvent {
  final String emailOrPhone;

  const SendResetCodeRequested(this.emailOrPhone);

  @override
  List<Object?> get props => [emailOrPhone];
}

/// Xác thực mã OTP 6 số
class VerifyOtpRequested extends ForgotPasswordEvent {
  final String email;
  final String otp;

  const VerifyOtpRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

/// Gửi lại mã OTP (chống spam 60s)
class ResendOtpRequested extends ForgotPasswordEvent {
  final String email;

  const ResendOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Đặt lại mật khẩu mới
class ResetPasswordRequested extends ForgotPasswordEvent {
  final String email;
  final String otp;
  final String newPassword;
  final String? confirmPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword, confirmPassword];
}

/// Đặt lại trạng thái về ban đầu (hoặc quay lại đổi email)
class ForgotPasswordResetToInitial extends ForgotPasswordEvent {
  const ForgotPasswordResetToInitial();
}
