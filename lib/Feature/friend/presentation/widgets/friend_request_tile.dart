import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/friend/domain/entities/friend_entities.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Friend request suggestion tile with "Gửi lời mời" action button.
class FriendRequestTile extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onSendRequest;

  const FriendRequestTile({
    super.key,
    required this.request,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          AppAvatar(
            name: request.name,
            size: 50,
            imageUrl: request.avatarUrl,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onSendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: request.isSent
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF007DFE),
                foregroundColor: request.isSent
                    ? const Color(0xFF64748B)
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                request.isSent ? lang.requestSent : lang.sendRequest,
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
