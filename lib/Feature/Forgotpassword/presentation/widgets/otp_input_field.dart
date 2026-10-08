import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget nhập mã OTP 6 chữ số chuyên nghiệp, hỗ trợ Copy-Paste, Auto-focus,
/// hiệu ứng viền sáng và tương thích hoàn toàn trên Android & iOS.
class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool autoFocus;

  const OtpInputField({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.autoFocus = true,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _focusNode]),
      builder: (context, _) {
        final text = widget.controller.text;
        final isFocused = _focusNode.hasFocus;

        return Stack(
          alignment: Alignment.center,
          children: [
            // TextField ẩn bên dưới để nhận bàn phím và paste
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                height: 56,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  showCursor: false,
                  enableInteractiveSelection: true,
                  onChanged: (val) {
                    widget.onChanged?.call(val);
                    if (val.length == 6) {
                      widget.onCompleted?.call(val);
                    }
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // 6 ô số hiển thị trực quan
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final char = index < text.length ? text[index] : '';
                  final isCurrent = isFocused && index == text.length;
                  final isFilled = index < text.length;

                  Color borderColor;
                  Color bgColor;

                  if (widget.hasError) {
                    borderColor = const Color(0xFFEF4444);
                    bgColor = const Color(0xFFFEF2F2);
                  } else if (isCurrent) {
                    borderColor = const Color(0xFF007DFE);
                    bgColor = const Color(0xFFEFF6FF);
                  } else if (isFilled) {
                    borderColor = const Color(0xFF007DFE).withValues(alpha: 0.5);
                    bgColor = Colors.white;
                  } else {
                    borderColor = const Color(0xFFCBD5E1);
                    bgColor = const Color(0xFFF8FAFC);
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor,
                        width: (isCurrent || (widget.hasError && isFilled)) ? 2.0 : 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF007DFE).withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      char,
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: widget.hasError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
