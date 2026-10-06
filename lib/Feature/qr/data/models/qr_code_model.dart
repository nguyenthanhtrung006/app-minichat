import '../../domain/entities/qr_code_entity.dart';

class QrCodeModel extends QrCodeEntity {
  const QrCodeModel({
    required super.rawValue,
    required super.type,
    required super.title,
    super.subtitle,
    super.avatarUrl,
    super.actionPayload,
    required super.scannedAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      rawValue: json['rawValue'] as String? ?? '',
      type: QrCodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QrCodeType.text,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      actionPayload: json['actionPayload'] as String?,
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawValue': rawValue,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'avatarUrl': avatarUrl,
      'actionPayload': actionPayload,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  /// Parses a raw scanned string into a friendly QrCodeModel
  factory QrCodeModel.fromRawString(String raw) {
    final now = DateTime.now();

    // 1. Minichat User Profile URL format: minichat://user?name=...&phone=...
    if (raw.startsWith('minichat://user') || raw.contains('user?')) {
      final uri = Uri.tryParse(raw);
      final name = uri?.queryParameters['name'] ?? 'Người dùng MiniChat';
      final phone = uri?.queryParameters['phone'] ?? uri?.queryParameters['id'] ?? '@user';
      final avatar = uri?.queryParameters['avatar'] ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

      return QrCodeModel(
        rawValue: raw,
        type: QrCodeType.userProfile,
        title: name,
        subtitle: 'ID: $phone',
        avatarUrl: avatar,
        actionPayload: phone,
        scannedAt: now,
      );
    }

    // 2. Minichat Group Invite: minichat://group?name=...&code=...
    if (raw.startsWith('minichat://group')) {
      final uri = Uri.tryParse(raw);
      final groupName = uri?.queryParameters['name'] ?? 'Nhóm bạn thân MiniChat';
      final code = uri?.queryParameters['code'] ?? 'GRP-8899';

      return QrCodeModel(
        rawValue: raw,
        type: QrCodeType.groupInvite,
        title: groupName,
        subtitle: 'Mã nhóm: $code',
        avatarUrl:
            'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
        actionPayload: code,
        scannedAt: now,
      );
    }

    // 3. Web URL
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return QrCodeModel(
        rawValue: raw,
        type: QrCodeType.webUrl,
        title: 'Liên kết trang web',
        subtitle: raw,
        avatarUrl: null,
        actionPayload: raw,
        scannedAt: now,
      );
    }

    // 4. Default Plain Text
    return QrCodeModel(
      rawValue: raw,
      type: QrCodeType.text,
      title: 'Văn bản quét được',
      subtitle: raw,
      avatarUrl: null,
      actionPayload: raw,
      scannedAt: now,
    );
  }
}
