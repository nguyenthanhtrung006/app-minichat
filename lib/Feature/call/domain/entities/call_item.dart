enum CallDirection { incoming, outgoing, missed, video }

class CallItem {
  final String id;
  final String name;
  final String time;
  final CallDirection direction;
  final bool isVideo;
  final String? avatarUrl;

  const CallItem({
    required this.id,
    required this.name,
    required this.time,
    required this.direction,
    this.isVideo = false,
    this.avatarUrl,
  });

  String get labelText {
    switch (direction) {
      case CallDirection.incoming:
        return 'Đã gọi đến · $time';
      case CallDirection.outgoing:
        return 'Đã gọi đi · $time';
      case CallDirection.missed:
        return 'Cuộc gọi nhỡ · $time';
      case CallDirection.video:
        return 'Cuộc gọi video · $time';
    }
  }
}
