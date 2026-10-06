import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/call/domain/entities/call_item.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Reusable call history list tile with action call button on the right.
class CallHistoryTile extends StatelessWidget {
  final CallItem call;
  final VoidCallback onCall;

  const CallHistoryTile({
    super.key,
    required this.call,
    required this.onCall,
  });

  String _formatLabel(BuildContext context) {
    final lang = context.l10n;
    switch (call.direction) {
      case CallDirection.incoming:
        return '${lang.calledIncoming} · ${call.time}';
      case CallDirection.outgoing:
        return '${lang.calledOutgoing} · ${call.time}';
      case CallDirection.missed:
        return '${lang.missedCall} · ${call.time}';
      case CallDirection.video:
        return '${lang.videoCall} · ${call.time}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.5),
      child: Row(
        children: [
          // 1. Reusable Avatar
          AppAvatar(
            name: call.name,
            size: 50,
            imageUrl: call.avatarUrl,
          ),
          const SizedBox(width: 14),

          // 2. Call Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  call.name,
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
                    _buildDirectionIcon(),
                    const SizedBox(width: 5),
                    Text(
                      _formatLabel(context),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Trailing Call Action Button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onCall,
              padding: EdgeInsets.zero,
              icon: Icon(
                call.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                color: const Color(0xFF007DFE),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionIcon() {
    switch (call.direction) {
      case CallDirection.incoming:
        return const Icon(
          Icons.call_received_rounded,
          color: Color(0xFF22C55E),
          size: 14,
        );
      case CallDirection.outgoing:
        return const Icon(
          Icons.call_made_rounded,
          color: Color(0xFF22C55E),
          size: 14,
        );
      case CallDirection.missed:
        return const Icon(
          Icons.call_missed_rounded,
          color: Color(0xFFEF4444),
          size: 14,
        );
      case CallDirection.video:
        return const Icon(
          Icons.videocam_rounded,
          color: Color(0xFF007DFE),
          size: 15,
        );
    }
  }
}
