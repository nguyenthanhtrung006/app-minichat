import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/chat/domain/entities/chat_item.dart';

/// Reusable chat list tile. Optimized for 60fps ListView scrolling.
class ChatTile extends StatelessWidget {
  final ChatItem chat;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFE2E8F0).withValues(alpha: 0.3),
      highlightColor: const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            // 1. Reusable Avatar
            AppAvatar(
              name: chat.name,
              size: 52,
              isOnline: chat.isOnline,
              isGroup: chat.isGroup,
              imageUrl: chat.avatarUrl,
            ),
            const SizedBox(width: 14),

            // 2. Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight:
                                hasUnread ? FontWeight.w800 : FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chat.time,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w600,
                          color: hasUnread
                              ? const Color(0xFF007DFE)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubtitleContent(),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007DFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 19,
                            minHeight: 19,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleContent() {
    if (chat.isMissedCall) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.phone_missed_rounded,
            color: Color(0xFFEF4444),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      );
    }

    if (chat.hasPhoto) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn: Hình ảnh ',
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const Icon(
            Icons.image_outlined,
            color: Color(0xFF94A3B8),
            size: 15,
          ),
        ],
      );
    }

    return Text(
      chat.lastMessage,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.nunito(
        fontSize: 13.5,
        fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
        color: chat.unreadCount > 0
            ? const Color(0xFF334155)
            : const Color(0xFF64748B),
      ),
    );
  }
}
