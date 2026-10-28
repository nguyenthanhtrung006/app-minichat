import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:minichatapp/core/network/friend_api_client.dart';
import 'package:minichatapp/Feature/account/data/datasources/account_remote_datasource.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../pages/my_qr_screen.dart';

class MyQrCodeDialog extends StatefulWidget {
  final String? userName;
  final String? userId;
  final String? avatarUrl;
  final String? qrCodeString;

  const MyQrCodeDialog({
    super.key,
    this.userName,
    this.userId,
    this.avatarUrl,
    this.qrCodeString,
  });

  @override
  State<MyQrCodeDialog> createState() => _MyQrCodeDialogState();
}

class _MyQrCodeDialogState extends State<MyQrCodeDialog> {
  late String _userName;
  late String _userId;
  String? _avatarUrl;
  late String _qrCodeString;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName ?? 'Người dùng Mini Chat';
    _userId = widget.userId ?? '@user';
    _avatarUrl = widget.avatarUrl;
    _qrCodeString = widget.qrCodeString ?? 'minichat://add/user_me';

    if (widget.userName == null || widget.qrCodeString == null) {
      _loadCurrentUserProfile();
    }
  }

  Future<void> _loadCurrentUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await AccountRemoteDataSourceImpl().getUserProfile();
      final myQrData = await FriendApiClient().getMyQr();
      final serverQr = myQrData?['qrCodeString']?.toString();
      if (mounted) {
        setState(() {
          _userName = profile.fullName;
          _userId = profile.username;
          _avatarUrl = profile.avatarUrl;
          _qrCodeString = serverQr ??
              'minichat://add/${profile.id}?name=${Uri.encodeComponent(profile.fullName)}&avatar=${Uri.encodeComponent(profile.avatarUrl ?? '')}';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút mở toàn màn hình
                IconButton(
                  tooltip: 'Xem toàn màn hình',
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: Color(0xFF007DFE),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MyQrScreen(
                          qrCodeString: _qrCodeString,
                          fullName: _userName,
                          avatarUrl: _avatarUrl,
                        ),
                      ),
                    );
                  },
                ),
                // Close button top right
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF007DFE)),
                ),
              )
            else ...[
              // User Info
              AppAvatar(
                name: _userName,
                size: 64,
                imageUrl: _avatarUrl,
              ),
              const SizedBox(height: 12),
              Text(
                _userName,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                _userId,
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 16),

              // QR Code Container with real QrImageView
              Container(
                padding: const EdgeInsets.all(14),
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
                child: QrImageView(
                  data: _qrCodeString,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),

              const SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }
}
