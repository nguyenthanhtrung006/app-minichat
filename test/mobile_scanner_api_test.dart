import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/qr/data/models/qr_code_model.dart';
import 'package:minichatapp/Feature/qr/domain/entities/qr_code_entity.dart';

void main() {
  group('QrCodeModel parser tests', () {
    test('parses minichat user profile URI properly', () {
      final model = QrCodeModel.fromRawString(
        'minichat://user?name=Nguyen Van A&phone=0901234567',
      );
      expect(model.type, equals(QrCodeType.userProfile));
      expect(model.title, equals('Nguyen Van A'));
      expect(model.actionPayload, equals('0901234567'));
    });

    test('parses group invite URI properly', () {
      final model = QrCodeModel.fromRawString(
        'minichat://group?name=Dev Team&code=GRP-99',
      );
      expect(model.type, equals(QrCodeType.groupInvite));
      expect(model.title, equals('Dev Team'));
      expect(model.actionPayload, equals('GRP-99'));
    });

    test('parses minichat add friend link properly', () {
      final model = QrCodeModel.fromRawString('minichat://add/8f7a91a2b3c4');
      expect(model.type, equals(QrCodeType.userProfile));
      expect(model.title, equals('Người bạn #8f7a91a2b3c4'));
      expect(model.actionPayload, equals('8f7a91a2b3c4'));
    });
  });
}
