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

  FriendRequest copyWith({bool? isSent}) {
    return FriendRequest(
      id: id,
      name: name,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      isSent: isSent ?? this.isSent,
    );
  }
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
}
