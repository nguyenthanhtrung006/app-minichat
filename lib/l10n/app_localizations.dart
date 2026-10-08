import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

/// Controller for managing locale without any Cubit or BLoC.
/// Uses standard Flutter [ValueNotifier].
class LocaleController {
  static final ValueNotifier<Locale> currentLocale =
      ValueNotifier<Locale>(const Locale('vi'));

  static void changeLocale(Locale locale) {
    if (currentLocale.value.languageCode != locale.languageCode) {
      currentLocale.value = locale;
    }
  }

  static void toggleLocale() {
    if (currentLocale.value.languageCode == 'vi') {
      currentLocale.value = const Locale('en');
    } else {
      currentLocale.value = const Locale('vi');
    }
  }

  static bool get isVietnamese => currentLocale.value.languageCode == 'vi';

  /// Get current AppLocalizations instance without context
  static AppLocalizations get instance =>
      isVietnamese ? AppLocalizationsVi() : AppLocalizationsEn();
}

/// Abstract base class for internationalization matching Flutter gen-l10n pattern.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('vi'),
    Locale('en'),
  ];

  // App
  String get appName;
  String get appSlogan;
  String get loading;

  // Language
  String get selectLanguage;
  String get vietnamese;
  String get english;

  // Auth / Login
  String get login;
  String get register;
  String get registerTitle;
  String get phoneOrEmail;
  String get phoneOrEmailHint;
  String get emailOrPhone;
  String get password;
  String get passwordHint;
  String get confirmPassword;
  String get confirmPasswordHint;
  String get fullName;
  String get fullNameHint;
  String get forgotPassword;
  String get forgotPasswordTitle;
  String get forgotPasswordInstruction;
  String get sendCode;
  String get backToLogin;
  String get orText;
  String get loginWithGoogle;
  String get loginWithFacebook;
  String get dontHaveAccount;
  String get alreadyHaveAccount;
  String get registerSuccess;
  String get resetCodeSentPrefix;
  String get otpVerification;
  String get enterOtp;
  String get otpMustBe6Digits;
  String get resendOtp;
  String get resendOtpIn;
  String get newPassword;
  String get newPasswordHint;
  String get confirmNewPassword;
  String get confirmNewPasswordHint;
  String get resetPasswordButton;
  String get resetPasswordSuccess;
  String get changeEmail;
  String get otpSentToEmail;

  // Validation
  String get enterEmailOrPhone;
  String get enterPassword;
  String get enterFullName;
  String get passwordMinLength;
  String get passwordNotMatch;
  String get enterConfirmPassword;

  // Bottom Navigation
  String get tabChat;
  String get tabFriends;
  String get tabCall;
  String get tabProfile;

  // Chats
  String get chatsTitle;
  String get searchChats;
  String get noChatsFound;
  String get typeMessage;
  String get today;
  String get yesterday;
  String get online;
  String get offline;
  String get me;
  String get image;
  String get camera;
  String get file;
  String get emoji;
  String get missedCall;
  String get sentDocument;
  String get typing;

  // Friends
  String get friendsTitle;
  String get searchFriends;
  String get friendRequests;
  String get friendsList;
  String get sendRequest;
  String get requestSent;
  String get noFriendsFound;

  // Calls
  String get callTitle;
  String get voiceCall;
  String get videoCall;
  String get callFriends;
  String get freeVideoCall;
  String get recentCalls;
  String get incomingCall;
  String get videoCallIncoming;
  String get outgoingCall;
  String get videoCallOutgoing;
  String get callDeclined;
  String get youDeclinedCall;
  String get mic;
  String get speaker;
  String get video;
  String get incomingCallFrom;
  String get calledIncoming;
  String get calledOutgoing;
  String get noAnswer;
  String get recipientNoAnswer;
  String get weakNetwork;
  String get weakNetworkWarning;
  String get simulateWeakNetwork;
  String get simulateNoAnswer;

  // Profile
  String get personalInfo;
  String get photosAndVideos;
  String get posts;
  String get groups;
  String get saved;
  String get settings;
  String get editProfile;
  String get updateStatus;
  String get whatOnYourMind;
  String get editProfileSnackBar;

  // Onboarding
  String get next;
  String get start;
  String get landingTitle1;
  String get landingSubtitle1;
  String get landingTitle2;
  String get landingSubtitle2;

  // QR Code
  String get tabQr;
  String get scanQr;
  String get qrScanInstruction;
  String get myQrCode;
  String get flash;
  String get gallery;
  String get qrResult;
  String get qrFriendFound;
  String get qrInvalid;
  String get addFriend;
  String get sendMessage;
  String get copyContent;
  String get simulateScan;
  String get copiedToClipboard;
  String get myQrCodeDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
    default:
      return AppLocalizationsVi();
  }
}

/// Helper for Intl canonicalizedLocale
class Intl {
  static String canonicalizedLocale(String? locale) {
    if (locale == null || locale.isEmpty) return 'vi';
    return locale;
  }
}

/// Convenient extension on BuildContext
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? LocaleController.instance;
}
