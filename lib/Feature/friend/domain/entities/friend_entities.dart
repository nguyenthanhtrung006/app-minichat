class FriendRequest {
  final String id;
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final bool isSent;

  const FriendRequest({
    required this.id,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    this.isSent = false,
  });

  FriendRequest copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? avatarUrl,
    bool? isSent,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSent: isSent ?? this.isSent,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'avatarUrl': avatarUrl,
        'isSent': isSent,
      };

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        isSent: json['isSent'] as bool? ?? false,
      );
}

class FriendItem {
  final String id;
  final String name;
  final String status;
  final bool isOnline;
  final String? avatarUrl;

  const FriendItem({
    required this.id,
    required this.name,
    required this.status,
    required this.isOnline,
    this.avatarUrl,
  });

  FriendItem copyWith({
    String? id,
    String? name,
    String? status,
    bool? isOnline,
    String? avatarUrl,
  }) {
    return FriendItem(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'isOnline': isOnline,
        'avatarUrl': avatarUrl,
      };

  factory FriendItem.fromJson(Map<String, dynamic> json) => FriendItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        status: json['status']?.toString() ?? 'Đang hoạt động',
        isOnline: json['isOnline'] as bool? ?? true,
        avatarUrl: json['avatarUrl']?.toString(),
      );
}
