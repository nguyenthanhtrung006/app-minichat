import 'dart:convert';
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
    final trimmed = raw.trim();

    // 0. JSON string format: {"name": "...", "id": ...}
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final map = jsonDecode(trimmed);
        if (map is Map<String, dynamic>) {
          final name = map['fullName'] ??
              map['name'] ??
              map['userName'] ??
              'Người dùng Mini Chat';
          final id =
              map['id']?.toString() ?? map['userId']?.toString() ?? '@user';
          final avatar =
              map['avatarUrl']?.toString() ?? map['avatar']?.toString();
          final phone = map['phone']?.toString();
          return QrCodeModel(
            rawValue: raw,
            type: QrCodeType.userProfile,
            title: name.toString(),
            subtitle: phone != null ? 'SĐT: $phone' : 'ID: $id',
            avatarUrl: avatar ??
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            actionPayload: id,
            scannedAt: now,
          );
        }
      } catch (_) {}
    }

    // 1. Minichat Add Friend Link: minichat://add/... hoặc https://.../add/...
    if (trimmed.startsWith('minichat://add') ||
        (trimmed.startsWith('http') && trimmed.contains('/add/'))) {
      final uri = Uri.tryParse(trimmed);
      String code = '';
      if (uri != null && uri.pathSegments.isNotEmpty) {
        code = uri.pathSegments.last;
      } else {
        code = trimmed
            .replaceFirst('minichat://add/', '')
            .replaceFirst('minichat://add', '')
            .split('?')
            .first;
      }

      final queryName = uri?.queryParameters['name'];
      final queryAvatar = uri?.queryParameters['avatar'];
      final queryPhone = uri?.queryParameters['phone'];

      final title = queryName != null && queryName.trim().isNotEmpty
          ? queryName.trim()
          : (code.isNotEmpty ? 'Người bạn #$code' : 'Bạn bè Mini Chat');

      final subtitle = queryPhone != null && queryPhone.isNotEmpty
          ? 'SĐT: $queryPhone'
          : (code.isNotEmpty ? 'Mã liên kết: $code' : 'Mã kết bạn Mini Chat');

      return QrCodeModel(
        rawValue: raw,
        type: QrCodeType.userProfile,
        title: title,
        subtitle: subtitle,
        avatarUrl: queryAvatar?.isNotEmpty == true
            ? queryAvatar
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        actionPayload: code.isNotEmpty ? code : null,
        scannedAt: now,
      );
    }

    // 2. Minichat User Profile URL format: minichat://user?name=...&phone=...
    if (trimmed.startsWith('minichat://user') || trimmed.contains('user?')) {
      final uri = Uri.tryParse(trimmed);
      final name = uri?.queryParameters['name'] ?? 'Người dùng MiniChat';
      final phone = uri?.queryParameters['phone'] ??
          uri?.queryParameters['id'] ??
          '@user';
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

    // 3. Minichat Group Invite: minichat://group?name=...&code=...
    if (trimmed.startsWith('minichat://group')) {
      final uri = Uri.tryParse(trimmed);
      final groupName =
          uri?.queryParameters['name'] ?? 'Nhóm bạn thân MiniChat';
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

    // 4. Web URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return QrCodeModel(
        rawValue: raw,
        type: QrCodeType.webUrl,
        title: 'Liên kết trang web',
        subtitle: trimmed,
        avatarUrl: null,
        actionPayload: trimmed,
        scannedAt: now,
      );
    }

    // 5. Short ID or phone number (e.g. 0912345678, user_123, 8f7a91a2b3c4)
    if (!trimmed.contains('://') &&
        !trimmed.contains('\n') &&
        trimmed.length <= 40) {
      return QrCodeModel(
        rawValue: raw,
        type: QrCodeType.userProfile,
        title: 'Người dùng #$trimmed',
        subtitle: 'Mã: $trimmed',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        actionPayload: trimmed,
        scannedAt: now,
      );
    }

    // 6. Default Plain Text
    return QrCodeModel(
      rawValue: raw,
      type: QrCodeType.text,
      title: 'Văn bản quét được',
      subtitle: trimmed,
      avatarUrl: null,
      actionPayload: trimmed,
      scannedAt: now,
    );
  }
}
