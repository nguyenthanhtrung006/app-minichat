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
  const ForgotPasswordLoading();
}

class ForgotPasswordCodeSent extends ForgotPasswordState {
  final String emailOrPhone;

  const ForgotPasswordCodeSent(this.emailOrPhone);

  @override
  List<Object?> get props => [emailOrPhone];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;

  const ForgotPasswordFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
