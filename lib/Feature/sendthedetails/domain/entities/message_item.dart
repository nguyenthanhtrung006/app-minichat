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

  /// Chuyển đổi dữ liệu nhận từ SignalR Realtime Hub
  factory MessageItem.fromSignalR(
    dynamic data, {
    bool isMe = false,
    String? defaultSenderName,
  }) {
    if (data is Map) {
      final text = data['content']?.toString() ??
          data['text']?.toString() ??
          data['message']?.toString() ??
          '';
      final senderName = data['senderName']?.toString() ??
          defaultSenderName ??
          (isMe ? 'Tôi' : 'Đối phương');
      final timeRaw = data['createdAt']?.toString() ?? '';
      String timeStr;
      if (timeRaw.isNotEmpty) {
        final dt = DateTime.tryParse(timeRaw)?.toLocal();
        timeStr = dt != null
            ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
            : '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      } else {
        final now = DateTime.now();
        timeStr =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }

      return MessageItem(
        id: data['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        time: timeStr,
        isMe: isMe,
        senderName: senderName,
        avatarUrl: data['avatarUrl']?.toString(),
        isRead: true,
      );
    }

    final now = DateTime.now();
    return MessageItem(
      id: now.millisecondsSinceEpoch.toString(),
      text: data?.toString() ?? '',
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      isMe: isMe,
      senderName: defaultSenderName ?? (isMe ? 'Tôi' : 'Đối phương'),
      isRead: true,
    );
  }
}
