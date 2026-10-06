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

    test('parses standard URL properly', () {
      final model = QrCodeModel.fromRawString('https://flutter.dev');
      expect(model.type, equals(QrCodeType.webUrl));
      expect(model.actionPayload, equals('https://flutter.dev'));
    });
  });
}
