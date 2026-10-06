import 'package:equatable/equatable.dart';
import '../../domain/repositories/login_repository.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String emailOrPhone;
  final String password;

  const LoginSubmitted({
    required this.emailOrPhone,
    required this.password,
  });

  @override
  List<Object?> get props => [emailOrPhone, password];
}

class LoginWithSocialRequested extends LoginEvent {
  final SocialProvider provider;

  const LoginWithSocialRequested(this.provider);

  @override
  List<Object?> get props => [provider];
}
