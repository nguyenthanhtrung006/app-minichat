import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/splash/presentation/pages/splash_page.dart';
import 'package:minichatapp/Feature/splash/presentation/widgets/splash_floating_bubble.dart';
import 'package:minichatapp/Feature/splash/presentation/widgets/splash_paper_plane.dart';
import 'package:minichatapp/Feature/splash/presentation/widgets/splash_progress_bar.dart';

void main() {
  testWidgets('SplashPage renders logo, title, slogan, and loading widgets',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Title & Slogan
    expect(find.text('Mini Chat'), findsOneWidget);
    expect(find.text('Kết nối mọi khoảnh khắc 💙'), findsOneWidget);

    // Verify key widgets
    expect(find.byType(Image), findsWidgets);
    expect(find.byType(SplashPaperPlane), findsOneWidget);
    expect(find.byType(SplashFloatingBubble), findsOneWidget);
    expect(find.byType(SplashProgressBar), findsOneWidget);

    // Fast-forward initialization delays
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
  });
}
