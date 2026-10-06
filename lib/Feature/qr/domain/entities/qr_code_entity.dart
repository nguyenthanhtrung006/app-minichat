import 'package:equatable/equatable.dart';

enum QrCodeType {
  userProfile,
  groupInvite,
  webUrl,
  text,
}

class QrCodeEntity extends Equatable {
  final String rawValue;
  final QrCodeType type;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final String? actionPayload;
  final DateTime scannedAt;

  const QrCodeEntity({
    required this.rawValue,
    required this.type,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.actionPayload,
    required this.scannedAt,
  });

  @override
  List<Object?> get props => [
        rawValue,
        type,
        title,
        subtitle,
        avatarUrl,
        actionPayload,
        scannedAt,
      ];
}
