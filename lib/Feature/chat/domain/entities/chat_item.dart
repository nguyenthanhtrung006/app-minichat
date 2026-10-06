class ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final bool isMissedCall;
  final bool hasPhoto;
  final String? avatarUrl;

  const ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.isMissedCall = false,
    this.hasPhoto = false,
    this.avatarUrl,
  });
}
