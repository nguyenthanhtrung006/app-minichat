import 'package:equatable/equatable.dart';

/// User entity đại diện cho thông tin người dùng theo cấu trúc mục 3 trong Docs (UserDto)
class UserEntity extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final String? createdAt;
  final String? lastSeenAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.isOnline = true,
    this.createdAt,
    this.lastSeenAt,
  });

  /// Getter tương thích ngược cho các màn hình hoặc test cũ sử dụng emailOrPhone
  String get emailOrPhone => email;

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        bio,
        isOnline,
        createdAt,
        lastSeenAt,
      ];
}
