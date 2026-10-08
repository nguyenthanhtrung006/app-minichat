import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Helper tiện ích cho phép chụp ảnh đại diện từ máy ảnh hoặc chọn ảnh từ thư viện
class AvatarPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Hiển thị BottomSheet lựa chọn nguồn ảnh (Camera hoặc Gallery)
  /// Trả về File ảnh đã chọn hoặc null nếu người dùng hủy
  static Future<File?> showAvatarPickerBottomSheet(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thanh kéo nhẹ phía trên
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Tiêu đề
                Text(
                  'Ảnh đại diện',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn cách bạn muốn cập nhật ảnh đại diện',
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // 1. Chụp ảnh từ Camera
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF007DFE),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Chụp ảnh mới (Máy ảnh)',
                    style: GoogleFonts.nunito(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Text(
                    'Mở camera để chụp ảnh trực tiếp',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onTap: () async {
                    final file = await _pickImage(ImageSource.camera);
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop(file);
                    }
                  },
                ),

                const SizedBox(height: 6),

                // 2. Chọn ảnh từ Thư viện
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF16A34A),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Chọn ảnh từ thư viện',
                    style: GoogleFonts.nunito(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Text(
                    'Chọn ảnh có sẵn trên điện thoại của bạn',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onTap: () async {
                    final file = await _pickImage(ImageSource.gallery);
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop(file);
                    }
                  },
                ),

                const SizedBox(height: 12),

                // 3. Nút Hủy
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                      backgroundColor: const Color(0xFFF8FAFC),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hàm phụ trợ gọi ImagePicker
  static Future<File?> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        return File(picked.path);
      }
    } catch (e) {
      debugPrint('⚠️ [AvatarPickerHelper Error]: Không thể chọn ảnh: $e');
    }
    return null;
  }
}
