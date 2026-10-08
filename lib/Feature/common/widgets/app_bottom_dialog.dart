import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Các loại trạng thái của Bottom Dialog
enum AppBottomDialogType {
  success,
  error,
  warning,
  info,
}

/// Dialog dạng Bottom Sheet có thể tái sử dụng trên toàn bộ ứng dụng:
/// Hỗ trợ thông báo thành công, lỗi, cảnh báo, xác nhận thông tin.
class AppBottomDialog extends StatelessWidget {
  final AppBottomDialogType type;
  final String title;
  final String? message;
  final Widget? content;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final IconData? customIcon;
  final Widget? customIconWidget;

  const AppBottomDialog({
    super.key,
    this.type = AppBottomDialogType.info,
    required this.title,
    this.message,
    this.content,
    this.primaryButtonText = 'Đồng ý',
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.customIcon,
    this.customIconWidget,
  });

  /// Hiển thị Dialog thông báo Thành Công dạng Bottom Sheet
  static Future<T?> showSuccess<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String primaryButtonText = 'Đồng ý',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return show<T>(
      context: context,
      type: AppBottomDialogType.success,
      title: title,
      message: message,
      content: content,
      primaryButtonText: primaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Hiển thị Dialog thông báo Lỗi dạng Bottom Sheet
  static Future<T?> showError<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String primaryButtonText = 'Đóng',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return show<T>(
      context: context,
      type: AppBottomDialogType.error,
      title: title,
      message: message,
      content: content,
      primaryButtonText: primaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Hiển thị Dialog Cảnh Báo dạng Bottom Sheet
  static Future<T?> showWarning<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String primaryButtonText = 'Đã hiểu',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return show<T>(
      context: context,
      type: AppBottomDialogType.warning,
      title: title,
      message: message,
      content: content,
      primaryButtonText: primaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Hiển thị Dialog Thông Tin chung dạng Bottom Sheet
  static Future<T?> showInfo<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String primaryButtonText = 'Đồng ý',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return show<T>(
      context: context,
      type: AppBottomDialogType.info,
      title: title,
      message: message,
      content: content,
      primaryButtonText: primaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Hàm gốc hiển thị Modal Bottom Sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required AppBottomDialogType type,
    required String title,
    String? message,
    Widget? content,
    String primaryButtonText = 'Đồng ý',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    IconData? customIcon,
    Widget? customIconWidget,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppBottomDialog(
        type: type,
        title: title,
        message: message,
        content: content,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
        customIcon: customIcon,
        customIconWidget: customIconWidget,
      ),
    );
  }

  Color _getPrimaryColor() {
    switch (type) {
      case AppBottomDialogType.success:
        return const Color(0xFF16A34A); // Emerald Green
      case AppBottomDialogType.error:
        return const Color(0xFFEF4444); // Red
      case AppBottomDialogType.warning:
        return const Color(0xFFF59E0B); // Amber
      case AppBottomDialogType.info:
        return const Color(0xFF007DFE); // Brand Blue
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AppBottomDialogType.success:
        return const Color(0xFFDCFCE7);
      case AppBottomDialogType.error:
        return const Color(0xFFFEE2E2);
      case AppBottomDialogType.warning:
        return const Color(0xFFFEF3C7);
      case AppBottomDialogType.info:
        return const Color(0xFFE0F2FE);
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case AppBottomDialogType.success:
        return Icons.check_circle_rounded;
      case AppBottomDialogType.error:
        return Icons.cancel_rounded;
      case AppBottomDialogType.warning:
        return Icons.warning_rounded;
      case AppBottomDialogType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final bgColor = _getBackgroundColor();
    final iconData = customIcon ?? _getDefaultIcon();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh gạt drag handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon biểu trưng với vòng hào quang 2 lớp
            customIconWidget ??
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        iconData,
                        size: 36,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 18),

            // Tiêu đề
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: 0.2,
              ),
            ),

            // Nội dung tin nhắn (nếu có)
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],

            // Custom Widget bổ sung (nếu có)
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],

            const SizedBox(height: 24),

            // Nút bấm chính (Primary Button)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onPrimaryPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == AppBottomDialogType.error
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF007DFE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  shadowColor: const Color(0xFF007DFE).withValues(alpha: 0.3),
                ),
                child: Text(
                  primaryButtonText,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Nút phụ (Secondary Button - nếu có)
            if (secondaryButtonText != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onSecondaryPressed?.call();
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  child: Text(
                    secondaryButtonText!,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
