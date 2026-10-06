import 'package:equatable/equatable.dart';

/// Parameters required to register a new user account.
class RegisterParams extends Equatable {
  final String fullName;
  final String emailOrPhone;
  final String password;
  final String confirmPassword;

  const RegisterParams({
    required this.fullName,
    required this.emailOrPhone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [fullName, emailOrPhone, password, confirmPassword];
}
