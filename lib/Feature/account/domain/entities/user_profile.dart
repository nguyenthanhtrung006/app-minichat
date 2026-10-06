class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String bio;
  final int friendsCount;
  final int postsCount;
  final int groupsCount;
  final bool isOnline;
  final String? avatarUrl;
  final String? coverUrl;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.bio,
    required this.friendsCount,
    required this.postsCount,
    required this.groupsCount,
    this.isOnline = true,
    this.avatarUrl,
    this.coverUrl,
  });
}
