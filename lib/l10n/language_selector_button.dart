import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_localizations.dart';

/// Language selector button that shows flags (covietnam.jpg & comy.jpg)
/// and toggles/selects languages without Cubit (using [LocaleController]).
class LanguageSelectorButton extends StatelessWidget {
  final bool compact;

  const LanguageSelectorButton({
    super.key,
    this.compact = false,
  });

  static const String flagVietnam = 'assets/images/covietnam.jpg';
  static const String flagUS = 'assets/images/comy.jpg';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.currentLocale,
      builder: (context, currentLocale, _) {
        final isVi = currentLocale.languageCode == 'vi';
        final currentFlag = isVi ? flagVietnam : flagUS;
        final currentLabel = isVi ? 'VN' : 'EN';

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            tooltip: isVi ? 'Chọn ngôn ngữ' : 'Select language',
            offset: const Offset(0, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            color: Colors.white,
            onSelected: (String code) {
              LocaleController.changeLocale(Locale(code));
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'vi',
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        flagVietnam,
                        width: 26,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tiếng Việt',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: isVi ? FontWeight.w800 : FontWeight.w600,
                          color: isVi ? const Color(0xFF007DFE) : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (isVi)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF007DFE),
                        size: 18,
                      ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        flagUS,
                        width: 26,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'English',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: !isVi ? FontWeight.w800 : FontWeight.w600,
                          color: !isVi ? const Color(0xFF007DFE) : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (!isVi)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF007DFE),
                        size: 18,
                      ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flag image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      currentFlag,
                      width: 24,
                      height: 16,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 16),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currentLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
