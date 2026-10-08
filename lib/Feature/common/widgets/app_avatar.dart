import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Highly optimized, reusable avatar widget used across all features:
/// Chat, Friend, Call, Account, and SendTheDetails.
///
/// Supports online green indicator badge, group icons, camera edit badge,
/// and smooth deterministic pastel gradient avatars when no image URL is provided.
class AppAvatar extends StatelessWidget {
  final double size;
  final String name;
  final String? imageUrl;
  final File? imageFile;
  final bool? isOnline;
  final bool isGroup;
  final bool showCameraBadge;
  final VoidCallback? onCameraTap;

  const AppAvatar({
    super.key,
    this.size = 50,
    required this.name,
    this.imageUrl,
    this.imageFile,
    this.isOnline,
    this.isGroup = false,
    this.showCameraBadge = false,
    this.onCameraTap,
  });

  // Palette of attractive modern pastel gradients based on user's name
  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF38BDF8), Color(0xFF0284C7)], // Sky Blue
    [Color(0xFF818CF8), Color(0xFF4F46E5)], // Indigo
    [Color(0xFFF472B6), Color(0xFFDB2777)], // Pink
    [Color(0xFF34D399), Color(0xFF059669)], // Emerald
    [Color(0xFFFBBF24), Color(0xFFD97706)], // Amber
    [Color(0xFFA78BFA), Color(0xFF7C3AED)], // Purple
    [Color(0xFFFB923C), Color(0xFFEA580C)], // Orange
    [Color(0xFF2DD4BF), Color(0xFF0D9488)], // Teal
  ];

  List<Color> _getGradientForName(String name) {
    if (name.isEmpty) return _avatarGradients[0];
    final hash = name.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    return _avatarGradients[hash % _avatarGradients.length];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[parts.length - 2][0] + parts[parts.length - 1][0])
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.28;
    final gradient = _getGradientForName(name);

    Widget avatarContent;

    if (isGroup) {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE0F2FE),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.groups_rounded,
            color: const Color(0xFF007DFE),
            size: size * 0.55,
          ),
        ),
      );
    } else if (imageFile != null) {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(imageFile!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      final ImageProvider imageProvider =
          (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))
              ? NetworkImage(imageUrl!)
              : FileImage(File(imageUrl!));

      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      avatarContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[1].withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getInitials(name),
            style: GoogleFonts.nunito(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    if (isOnline != true && !showCameraBadge) {
      return avatarContent;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,

        // Online green indicator dot
        if (isOnline == true && !showCameraBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: size > 60 ? 3 : 2,
                ),
              ),
            ),
          ),

        // Camera edit icon badge for Account page
        if (showCameraBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCameraTap,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: const Color(0xFF007DFE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: size * 0.18,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
