import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Feature/Login/presentation/pages/login_page.dart';
import '../storage/token_storage.dart';
import '../network/signalr_service.dart';

/// Quản lý phiên đăng nhập và ràng buộc 1 thiết bị duy nhất (Single Device Session).
/// Khi tài khoản được đăng nhập trên máy khác, hệ thống sẽ tự động đá máy hiện tại ra,
/// hiển thị popup thông báo và đưa về màn hình Đăng nhập.
class AuthSessionManager {
  static final AuthSessionManager _instance = AuthSessionManager._internal();
  static AuthSessionManager get instance => _instance;

  /// GlobalKey để điều hướng và hiển thị Dialog toàn cục không cần context của widget
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// ID duy nhất của phiên thiết bị hiện tại
  final String deviceSessionId =
      '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

  /// Email của tài khoản đang đăng nhập trên thiết bị này
  String? currentUserEmail;

  /// User ID của tài khoản đang đăng nhập trên thiết bị này
  String? currentUserId;

  bool _isForceLoggedOut = false;

  AuthSessionManager._internal();

  /// Đặt lại cờ sau khi người dùng đăng nhập thành công
  void onLoginSuccess({String? email, String? userId}) {
    _isForceLoggedOut = false;
    if (email != null && email.isNotEmpty) {
      currentUserEmail = email.toLowerCase().trim();
    }
    if (userId != null && userId.isNotEmpty) {
      currentUserId = userId.trim();
    }
  }

  /// Xử lý bị đăng xuất cưỡng bức khi phát hiện máy khác đăng nhập
  Future<void> handleForceLogout({
    String? reason,
  }) async {
    if (_isForceLoggedOut) return;
    _isForceLoggedOut = true;

    debugPrint('🚨 [AuthSessionManager]: Phát hiện phiên đăng nhập cùng tài khoản ($currentUserEmail) từ thiết bị khác! Tiến hành out...');

    // 1. Xóa token lưu trữ trong máy
    await TokenStorage.instance.deleteToken();

    // 2. Ngắt kết nối SignalR
    try {
      await SignalRService.instance.disconnect();
    } catch (_) {}

    currentUserEmail = null;
    currentUserId = null;

    final navContext = navigatorKey.currentContext;
    final message = reason ??
        'Tài khoản của bạn đã được đăng nhập trên một thiết bị khác. Vui lòng đăng nhập lại để tiếp tục sử dụng!';

    if (navContext != null && navContext.mounted) {
      unawaited(
        showDialog(
          context: navContext,
          barrierDismissible: false,
          builder: (ctx) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Phiên đăng nhập hết hạn',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                  height: 1.45,
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _navigateToLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007DFE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                    child: Text(
                      'Đăng nhập lại',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void dispose() {}
}
