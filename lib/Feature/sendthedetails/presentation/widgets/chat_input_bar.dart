import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Bottom chat text input bar matching Image 2.
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback onToggleAttachment;
  final bool isAttachmentOpen;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onToggleAttachment,
    required this.isAttachmentOpen,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final can = _controller.text.trim().isNotEmpty;
      if (can != _canSend) {
        setState(() => _canSend = can);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 1. Plus Action Button
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: widget.onToggleAttachment,
                padding: EdgeInsets.zero,
                icon: AnimatedRotation(
                  turns: widget.isAttachmentOpen ? 0.125 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF007DFE),
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Input Capsule
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          isCollapsed: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: lang.typeMessage,
                          hintStyle: GoogleFonts.nunito(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Icon(
                          Icons.sentiment_satisfied_alt_rounded,
                          color: Color(0xFF007DFE),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 3. Circular Send Button
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF007DFE),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleSend,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
