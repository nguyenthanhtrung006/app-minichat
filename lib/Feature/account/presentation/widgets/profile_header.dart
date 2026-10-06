import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Top profile header including mountain scenic cover, overlapping avatar,
/// name, bio, and stats row.
class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String username;
  final String bio;
  final int friendsCount;
  final int postsCount;
  final int groupsCount;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    this.fullName = 'Nguyễn Văn Nam',
    this.username = '@nguyenvannam',
    this.bio = 'Sống tích cực - Làm điều mình thích ☀️',
    this.friendsCount = 128,
    this.postsCount = 56,
    this.groupsCount = 12,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Column(
      children: [
        // 1. Cover Photo & Avatar Stack
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Cover Photo with Gradient Overlay
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF1E40AF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 4.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),

            // Overlapping Profile Avatar with Camera Button
            Positioned(
              bottom: -50,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: AppAvatar(
                  name: fullName,
                  size: 96,
                  showCameraBadge: true,
                  onCameraTap: () {},
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 56),

        // 2. Name & Bio
        Text(
          fullName,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          username,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          bio,
          style: GoogleFonts.nunito(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 10),

        // 3. Online Status Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                lang.online,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. Stats Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$friendsCount', lang.tabFriends),
              Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
              _buildStatItem('$postsCount', lang.posts),
              Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
              _buildStatItem('$groupsCount', lang.groups),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 5. Edit Profile CTA Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF007DFE),
                size: 18,
              ),
              label: Text(
                lang.editProfile,
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF007DFE),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF0F7FF),
                side: const BorderSide(
                  color: Color(0xFFBFDBFE),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
