import 'package:equatable/equatable.dart';

/// User entity representing authenticated user data.
class UserEntity extends Equatable {
  final String id;
  final String emailOrPhone;
  final String? fullName;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.emailOrPhone,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, emailOrPhone, fullName, avatarUrl];
}
