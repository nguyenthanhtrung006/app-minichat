import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Attachment drawer that expands when '+' button is pressed.
/// Includes 4 quick actions: 'Ảnh', 'Camera', 'Tệp', 'Emoji'.
class MediaAttachmentPanel extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickCamera;
  final VoidCallback onPickFile;
  final VoidCallback onPickEmoji;

  const MediaAttachmentPanel({
    super.key,
    required this.onPickImage,
    required this.onPickCamera,
    required this.onPickFile,
    required this.onPickEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            icon: Icons.image_rounded,
            label: lang.image,
            onTap: onPickImage,
          ),
          _buildItem(
            icon: Icons.camera_alt_rounded,
            label: lang.camera,
            onTap: onPickCamera,
          ),
          _buildItem(
            icon: Icons.insert_drive_file_rounded,
            label: lang.file,
            onTap: onPickFile,
          ),
          _buildItem(
            icon: Icons.sentiment_satisfied_alt_rounded,
            label: lang.emoji,
            onTap: onPickEmoji,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8FAFC),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF007DFE),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
