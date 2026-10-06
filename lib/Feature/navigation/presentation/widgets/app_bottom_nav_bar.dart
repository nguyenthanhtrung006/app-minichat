import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/qr/presentation/pages/qr_scanner_page.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

/// Reusable bottom navigation bar with a raised, circular center QR scanner button.
/// The QR button has a deep blue outer background ("xanh dương đậm lòi lên trên nhẹ")
/// and a lighter blue inner background ("nền trong kia xanh lạt hơn").
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onQrTap;
  final int chatBadgeCount;
  final int callBadgeCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onQrTap,
    this.chatBadgeCount = 2,
    this.callBadgeCount = 1,
  });

  void _handleQrTap(BuildContext context) {
    if (onQrTap != null) {
      onQrTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const QrScannerPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // 1. Navigation Bar Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
            border: const Border(
              top: BorderSide(
                color: Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  // Tab 0: Trò chuyện
                  _buildNavItem(
                    index: 0,
                    label: lang.tabChat,
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    badgeCount: chatBadgeCount,
                  ),

                  // Tab 1: Bạn bè
                  _buildNavItem(
                    index: 1,
                    label: lang.tabFriends,
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_rounded,
                  ),

                  // Center QR space with label
                  Expanded(
                    child: InkWell(
                      onTap: () => _handleQrTap(context),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 38),
                          Text(
                            lang.tabQr,
                            style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0052D4),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),

                  // Tab 2: Gọi
                  _buildNavItem(
                    index: 2,
                    label: lang.tabCall,
                    icon: Icons.phone_outlined,
                    activeIcon: Icons.phone_rounded,
                    badgeCount: callBadgeCount,
                  ),

                  // Tab 3: Cá nhân
                  _buildNavItem(
                    index: 3,
                    label: lang.tabProfile,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Elevated Center QR Circular Button ("lòi lên trên nhẹ")
        Positioned(
          top: -16,
          child: GestureDetector(
            onTap: () => _handleQrTap(context),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                // Deep blue outer background ("xanh dương đậm")
                color: const Color(0xFF0052D4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052D4).withValues(alpha: 0.38),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                // Lighter blue inner background ("nền trong kia xanh lạt hơn")
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF60A5FA),
                        Color(0xFF38BDF8),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF007DFE) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: color,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
