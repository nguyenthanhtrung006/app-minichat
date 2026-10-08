import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Settings and options menu card on the Account screen.
class ProfileMenuCard extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileMenuCard({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildItem(
            icon: Icons.person_outline_rounded,
            title: lang.personalInfo,
            onTap: () {},
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.photo_library_outlined,
            title: lang.photosAndVideos,
            onTap: () {},
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.edit_note_rounded,
            title: lang.posts,
            onTap: () {},
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.groups_outlined,
            title: lang.groups,
            onTap: () {},
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.bookmark_outline_rounded,
            title: lang.saved,
            onTap: () {},
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.settings_outlined,
            title: lang.settings,
            onTap: () {},
          ),
          if (onLogout != null) ...[
            _buildDivider(),
            _buildItem(
              icon: Icons.logout_rounded,
              title: 'Đăng xuất',
              iconColor: const Color(0xFFEF4444),
              textColor: const Color(0xFFEF4444),
              onTap: onLogout!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: Color(0xFFF1F5F9),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFE2E8F0).withValues(alpha: 0.3),
      highlightColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? const Color(0xFF475569),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor ?? const Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
