import '../../domain/entities/user_entity.dart';

/// User Model chuyển đổi JSON theo chuẩn DTO của Backend
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.avatarUrl,
    super.bio,
    super.isOnline = true,
    super.createdAt,
    super.lastSeenAt,
  });

  /// Parse dữ liệu JSON nhận được từ backend (Login, Register hoặc Get Me)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      lastSeenAt: json['lastSeenAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'lastSeenAt': lastSeenAt,
    };
  }
}
