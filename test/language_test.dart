import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import 'package:minichatapp/l10n/app_localizations_en.dart';
import 'package:minichatapp/l10n/app_localizations_vi.dart';
import 'package:minichatapp/l10n/language_selector_button.dart';

void main() {
  group('L10n & LocaleController Tests (No Cubit)', () {
    setUp(() {
      LocaleController.changeLocale(const Locale('vi'));
    });

    test('Default locale is Vietnamese', () {
      expect(LocaleController.currentLocale.value, const Locale('vi'));
      expect(LocaleController.isVietnamese, true);
      expect(LocaleController.instance.login, 'Đăng nhập');
      expect(LocaleController.instance, isA<AppLocalizationsVi>());
    });

    test('Switch to English updates texts', () {
      LocaleController.changeLocale(const Locale('en'));

      expect(LocaleController.currentLocale.value, const Locale('en'));
      expect(LocaleController.isVietnamese, false);
      expect(LocaleController.instance.login, 'Sign In');
      expect(LocaleController.instance.appSlogan, 'Connecting every moment 💙');
      expect(LocaleController.instance, isA<AppLocalizationsEn>());

      // Reset back to Vietnamese
      LocaleController.changeLocale(const Locale('vi'));
      expect(LocaleController.currentLocale.value, const Locale('vi'));
      expect(LocaleController.instance.login, 'Đăng nhập');
    });

    test('Toggle locale flips between Vietnamese and English', () {
      LocaleController.changeLocale(const Locale('vi'));

      LocaleController.toggleLocale();
      expect(LocaleController.currentLocale.value, const Locale('en'));

      LocaleController.toggleLocale();
      expect(LocaleController.currentLocale.value, const Locale('vi'));
    });

    test('lookupAppLocalizations returns correct localization subclass', () {
      final vi = lookupAppLocalizations(const Locale('vi'));
      expect(vi, isA<AppLocalizationsVi>());
      expect(vi.login, 'Đăng nhập');

      final en = lookupAppLocalizations(const Locale('en'));
      expect(en, isA<AppLocalizationsEn>());
      expect(en.login, 'Sign In');
    });

    testWidgets('LanguageSelectorButton renders flag image and code label',
        (WidgetTester tester) async {
      LocaleController.changeLocale(const Locale('vi'));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Center(
              child: LanguageSelectorButton(),
            ),
          ),
        ),
      );

      // Verify VN label exists
      expect(find.text('VN'), findsOneWidget);

      // Change locale to en
      LocaleController.changeLocale(const Locale('en'));
      await tester.pumpAndSettle();

      // Verify EN label exists
      expect(find.text('EN'), findsOneWidget);
    });
  });
}
