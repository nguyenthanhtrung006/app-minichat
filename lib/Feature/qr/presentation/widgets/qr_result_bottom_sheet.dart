import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/sendthedetails/presentation/pages/send_the_details_page.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../domain/entities/qr_code_entity.dart';

class QrResultBottomSheet extends StatelessWidget {
  final QrCodeEntity data;
  final VoidCallback onScanAgain;

  const QrResultBottomSheet({
    super.key,
    required this.data,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),

          // Header title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF007DFE),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                lang.qrResult,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                onPressed: () {
                  Navigator.of(context).pop();
                  onScanAgain();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 18),

          // Content Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                if (data.type == QrCodeType.userProfile)
                  AppAvatar(
                    name: data.title,
                    size: 54,
                    imageUrl: data.avatarUrl,
                  )
                else if (data.type == QrCodeType.groupInvite)
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007DFE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                else
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      data.type == QrCodeType.webUrl
                          ? Icons.link_rounded
                          : Icons.text_snippet_rounded,
                      color: const Color(0xFF0284C7),
                      size: 28,
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (data.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          data.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Actions
          if (data.type == QrCodeType.userProfile) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: Text(
                        lang.addFriend,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF007DFE),
                        side: const BorderSide(color: Color(0xFF007DFE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${lang.requestSent}: ${data.title}',
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: const Color(0xFF007DFE),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                        onScanAgain();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                      label: Text(
                        lang.sendMessage,
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
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SendTheDetailsPage(
                              contactName: data.title,
                              avatarUrl: data.avatarUrl,
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(
                  lang.copyContent,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007DFE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data.rawValue));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lang.copiedToClipboard,
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: const Color(0xFF007DFE),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop();
                  onScanAgain();
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Secondary Scan Again Button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onScanAgain();
            },
            child: Text(
              'Quét mã khác',
              style: GoogleFonts.nunito(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
