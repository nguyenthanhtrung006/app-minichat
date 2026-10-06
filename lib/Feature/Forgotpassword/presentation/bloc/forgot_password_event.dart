import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class SendResetCodeRequested extends ForgotPasswordEvent {
  final String emailOrPhone;

  const SendResetCodeRequested(this.emailOrPhone);

  @override
  List<Object?> get props => [emailOrPhone];
}
