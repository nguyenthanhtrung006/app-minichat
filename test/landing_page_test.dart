import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/langding/page/langding_page.dart';
import 'package:minichatapp/Feature/langding/presentation/widgets/connect_illustration_header.dart';
import 'package:minichatapp/Feature/langding/presentation/widgets/features_grid_header.dart';
import 'package:minichatapp/Feature/langding/presentation/widgets/landing_action_button.dart';
import 'package:minichatapp/Feature/langding/presentation/widgets/landing_next_button.dart';

void main() {
  testWidgets('LandingPage renders Connect Page (Page 1) initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Page 1 elements
    expect(find.text('Kết nối mọi người\nGần hơn'), findsOneWidget);
    expect(find.text('Nhắn tin • Gọi điện • Kết bạn • Nhóm'), findsOneWidget);
    expect(find.byType(ConnectIllustrationHeader), findsOneWidget);
    expect(find.byType(LandingNextButton), findsOneWidget);
  });

  testWidgets('LandingPage can swipe to All-In-One Page (Page 2) with CTA button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    await tester.pump(const Duration(milliseconds: 100));

    // Swipe to next page
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Page 2 elements
    expect(find.text('Tất cả trong một'), findsOneWidget);
    expect(find.text('Trò chuyện, gọi điện, chia sẻ và\nkết nối với bạn bè thật dễ dàng.'), findsOneWidget);
    expect(find.byType(FeaturesGridHeader), findsOneWidget);
    expect(find.byType(LandingActionButton), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
