import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/friend/domain/entities/friend_entities.dart';

/// Friend list tile showing online status and chevron right.
class FriendTile extends StatelessWidget {
  final FriendItem friend;
  final VoidCallback onTap;

  const FriendTile({
    super.key,
    required this.friend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFE2E8F0).withValues(alpha: 0.3),
      highlightColor: const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
        child: Row(
          children: [
            AppAvatar(
              name: friend.name,
              size: 50,
              isOnline: friend.isOnline,
              imageUrl: friend.avatarUrl,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    friend.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (friend.isOnline) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ] else ...[
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF94A3B8),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        friend.status,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: friend.isOnline
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF007DFE),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
