import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/calling/domain/entities/call_session.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/call_no_answer_view.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/outgoing_call_view.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('vi')],
    locale: const Locale('vi'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OutgoingCallView & CallNoAnswerView Tests', () {
    testWidgets('OutgoingCallView renders caller info and NO fake simulation chips',
        (tester) async {
      const session = CallSession(
        callerName: 'Nguyễn Văn A',
        callType: CallType.audio,
        callStatus: CallStatus.outgoing,
      );

      await tester.pumpWidget(
        createTestApp(
          OutgoingCallView(
            session: session,
            onCancel: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check caller name and outgoing status
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Đang đổ chuông...'), findsOneWidget);

      // Verify fake test chips are completely removed
      expect(find.text('Nhấc máy'), findsNothing);
      expect(find.text('Không nghe máy'), findsNothing);
      expect(find.text('Không trả lời'), findsNothing);
    });

    testWidgets('CallNoAnswerView displays offline message when recipient is offline',
        (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        createTestApp(
          CallNoAnswerView(
            message: 'Người nhận hiện không trực tuyến.',
            onDismiss: () {
              dismissed = true;
            },
          ),
        ),
      );
      await tester.pump();

      // Should show offline title and custom message
      expect(find.text('Đối phương không trực tuyến'), findsOneWidget);
      expect(
        find.textContaining('Người nhận hiện không trực tuyến.'),
        findsOneWidget,
      );
      expect(find.text('Thông báo: Người nhận đang Offline'), findsOneWidget);

      // Tap close button
      await tester.tap(find.text('Đóng'));
      expect(dismissed, isTrue);
    });
  });
}
