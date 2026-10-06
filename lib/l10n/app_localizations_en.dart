import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = 'en']);

  @override
  String get appName => 'Mini Chat';

  @override
  String get appSlogan => 'Connecting every moment 💙';

  @override
  String get loading => 'Loading...';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get phoneOrEmail => 'Phone / Email';

  @override
  String get phoneOrEmailHint => 'Enter phone number or email';

  @override
  String get emailOrPhone => 'Email or phone number';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Minimum 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordInstruction =>
      'Enter your email or phone number,\nwe will send you a verification code.';

  @override
  String get sendCode => 'Send Code';

  @override
  String get backToLogin => 'Back to Sign In';

  @override
  String get orText => 'Or';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithFacebook => 'Sign in with Facebook';

  @override
  String get dontHaveAccount => "Don't have an account? ";

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get registerSuccess => 'Registration successful! Please sign in.';

  @override
  String get resetCodeSentPrefix => 'Verification code sent to';

  @override
  String get enterEmailOrPhone => 'Please enter phone number or email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get enterFullName => 'Please enter your full name';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordNotMatch => 'Confirm password does not match';

  @override
  String get enterConfirmPassword => 'Please confirm your password';

  @override
  String get tabChat => 'Chats';

  @override
  String get tabFriends => 'Friends';

  @override
  String get tabCall => 'Calls';

  @override
  String get tabProfile => 'Profile';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get searchChats => 'Search conversations';

  @override
  String get noChatsFound => 'No conversations found';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get me => 'Me';

  @override
  String get image => 'Photo';

  @override
  String get camera => 'Camera';

  @override
  String get file => 'File';

  @override
  String get emoji => 'Emoji';

  @override
  String get missedCall => 'Missed call';

  @override
  String get sentDocument => 'Sent a document';

  @override
  String get typing => 'Typing...';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get searchFriends => 'Search friends';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get friendsList => 'Friends';

  @override
  String get sendRequest => 'Add Friend';

  @override
  String get requestSent => 'Sent';

  @override
  String get noFriendsFound => 'No friends found';

  @override
  String get callTitle => 'Calls';

  @override
  String get voiceCall => 'Voice Call';

  @override
  String get videoCall => 'Video Call';

  @override
  String get callFriends => 'Call your friends';

  @override
  String get freeVideoCall => 'Free video call';

  @override
  String get recentCalls => 'Recent';

  @override
  String get incomingCall => 'Incoming call...';

  @override
  String get videoCallIncoming => 'Incoming video call...';

  @override
  String get outgoingCall => 'Calling...';

  @override
  String get videoCallOutgoing => 'Video calling...';

  @override
  String get callDeclined => 'Call Declined';

  @override
  String get youDeclinedCall => 'You declined the call';

  @override
  String get mic => 'Mic';

  @override
  String get speaker => 'Speaker';

  @override
  String get video => 'Video';

  @override
  String get incomingCallFrom => 'Incoming call';

  @override
  String get calledIncoming => 'Incoming';

  @override
  String get calledOutgoing => 'Outgoing';

  @override
  String get noAnswer => 'No Answer';

  @override
  String get recipientNoAnswer => 'Recipient is not answering';

  @override
  String get weakNetwork => 'Weak Network';

  @override
  String get weakNetworkWarning => 'Weak network connection, signal unstable...';

  @override
  String get simulateWeakNetwork => 'Weak Network';

  @override
  String get simulateNoAnswer => 'No Answer';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get photosAndVideos => 'Photos & Videos';

  @override
  String get posts => 'Posts';

  @override
  String get groups => 'Groups';

  @override
  String get saved => 'Saved';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get whatOnYourMind => "What's on your mind?";

  @override
  String get editProfileSnackBar => 'Opening edit profile...';

  @override
  String get next => 'Next';

  @override
  String get start => 'Get Started';

  @override
  String get landingTitle1 => 'Connecting People\nCloser';

  @override
  String get landingSubtitle1 => 'Messaging • Calling • Friends • Groups';

  @override
  String get landingTitle2 => 'All in One';

  @override
  String get landingSubtitle2 =>
      'Chat, call, share and connect\nwith friends with ease.';

  // QR Code
  @override
  String get tabQr => 'Scan QR';

  @override
  String get scanQr => 'Scan QR Code';

  @override
  String get qrScanInstruction => 'Point camera at the QR code to scan';

  @override
  String get myQrCode => 'My QR Code';

  @override
  String get flash => 'Flashlight';

  @override
  String get gallery => 'Gallery';

  @override
  String get qrResult => 'Scan Result';

  @override
  String get qrFriendFound => 'User Found';

  @override
  String get qrInvalid => 'Invalid QR code';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get copyContent => 'Copy';

  @override
  String get simulateScan => 'Test Sample QR';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get myQrCodeDesc =>
      'Show this code to your friends to connect instantly';
}
