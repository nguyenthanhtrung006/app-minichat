import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:minichatapp/Feature/qr/presentation/pages/my_qr_screen.dart';
import 'package:minichatapp/Feature/qr/presentation/widgets/my_qr_code_dialog.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

void main() {
  group('MyQrScreen & QR Code Widgets Tests', () {
    testWidgets('MyQrScreen renders title, user name, and QrImageView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyQrScreen(
            qrCodeString: 'minichat://add/user_test_123',
            fullName: 'Nguyễn Thanh Trung',
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('Mã QR của tôi'), findsOneWidget);

      // Verify user full name
      expect(find.text('Nguyễn Thanh Trung'), findsOneWidget);

      // Verify hint message
      expect(
        find.text('Quét mã này để kết bạn trên Mini Chat'),
        findsOneWidget,
      );

      // Verify raw code and copy button exist
      expect(find.text('minichat://add/user_test_123'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      // Verify QrImageView exists in widget tree
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('MyQrScreen share button triggers feedback snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyQrScreen(
            qrCodeString: 'minichat://add/user_test_123',
            fullName: 'Nguyễn Thanh Trung',
          ),
        ),
      );

      final shareBtn = find.text('Chia sẻ mã QR');
      expect(shareBtn, findsOneWidget);

      await tester.ensureVisible(shareBtn);
      await tester.tap(shareBtn);
      await tester.pump();

      expect(find.text('Mã QR đã sẵn sàng để chia sẻ!'), findsOneWidget);
    });

    testWidgets('MyQrCodeDialog renders with QrImageView and user info',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: Scaffold(
            body: MyQrCodeDialog(
              userName: 'Trần Văn B',
              userId: '@tranvanb',
              qrCodeString: 'minichat://add/tranvanb_99',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Trần Văn B'), findsOneWidget);
      expect(find.text('@tranvanb'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
    });
  });
}
