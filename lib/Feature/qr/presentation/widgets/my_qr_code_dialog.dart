import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

class MyQrCodeDialog extends StatelessWidget {
  final String userName;
  final String userId;
  final String? avatarUrl;

  const MyQrCodeDialog({
    super.key,
    this.userName = 'Nguyễn Văn Nam',
    this.userId = '@nguyenvannam',
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button top right
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // User Info
            AppAvatar(
              name: userName,
              size: 64,
              imageUrl: avatarUrl,
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              userId,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 20),

            // QR Code Container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007DFE).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _SimulatedQrPainter(),
                  ),
                  // Center mini badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFF007DFE),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Instruction text
            Text(
              lang.myQrCodeDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 20),

            // Share / Save Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  'Chia sẻ mã QR',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007DFE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã chia sẻ mã QR thành công!',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: const Color(0xFF007DFE),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulatedQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    const int grid = 21;
    final double step = size.width / grid;

    // Draw standard 3 Corner Squares (Finder patterns)
    void drawFinder(double x, double y) {
      // Outer 7x7
      canvas.drawRect(
        Rect.fromLTWH(x * step, y * step, 7 * step, 7 * step),
        paint,
      );
      // Inner clear 5x5
      canvas.drawRect(
        Rect.fromLTWH((x + 1) * step, (y + 1) * step, 5 * step, 5 * step),
        Paint()..color = Colors.white,
      );
      // Center solid 3x3
      canvas.drawRect(
        Rect.fromLTWH((x + 2) * step, (y + 2) * step, 3 * step, 3 * step),
        paint,
      );
    }

    drawFinder(0, 0);
    drawFinder(14, 0);
    drawFinder(0, 14);

    // Decorative pseudorandom QR modules
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        // Skip finder pattern zones
        final inTL = r < 8 && c < 8;
        final inTR = r < 8 && c >= 13;
        final inBL = r >= 13 && c < 8;
        final inCenter = (r >= 8 && r <= 12) && (c >= 8 && c <= 12);

        if (inTL || inTR || inBL || inCenter) continue;

        // Hash pattern for stable dots
        if (((r * 17 + c * 31 + (r * c)) % 3) != 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                c * step + 0.8,
                r * step + 0.8,
                step - 1.6,
                step - 1.6,
              ),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
