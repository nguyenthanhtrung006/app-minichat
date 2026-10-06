class MessageItem {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String senderName;
  final String? avatarUrl;
  final bool isRead;

  const MessageItem({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderName,
    this.avatarUrl,
    this.isRead = true,
  });
}
