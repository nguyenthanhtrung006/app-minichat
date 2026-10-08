import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lớp quản lý lưu trữ JWT Token an toàn theo khuyến nghị mục 4.1 của Docs:
/// "Flutter: Sử dụng flutter_secure_storage thay vì shared_preferences thông thường để bảo mật token."
/// Tích hợp cơ chế fallback bộ nhớ tạm để không bao giờ bị lỗi MissingPluginException khi Hot Reload.
class TokenStorage {
  static const String _tokenKey = 'jwt_access_token';
  final FlutterSecureStorage _storage;

  // Bộ nhớ đệm RAM dự phòng (giữ token ngay cả khi plugin native chưa được rebuild)
  String? _inMemoryToken;

  // Singleton instance tiện lợi khi gọi toàn cục
  static final TokenStorage instance = TokenStorage();

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Lưu JWT Token sau khi Đăng ký hoặc Đăng nhập thành công
  Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
      debugPrint('💾 [TokenStorage]: Đã lưu token thành công vào Secure Storage.');
    } catch (e) {
      debugPrint('⚠️ [TokenStorage Cảnh Báo]: Chưa thể ghi vào Secure Storage ($e). Đã lưu vào bộ nhớ tạm.');
    }
  }

  /// Lấy JWT Token đã lưu để đính kèm vào Header Authorization: Bearer {token}
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (e) {
      debugPrint('⚠️ [TokenStorage Cảnh Báo]: Lỗi đọc Secure Storage ($e). Dùng token từ bộ nhớ tạm.');
    }
    return _inMemoryToken;
  }

  /// Xóa token khi Đăng xuất hoặc khi nhận mã lỗi 401 Unauthorized
  Future<void> deleteToken() async {
    _inMemoryToken = null;
    try {
      await _storage.delete(key: _tokenKey);
      debugPrint('🗑️ [TokenStorage]: Đã xóa token khỏi Secure Storage.');
    } catch (e) {
      debugPrint('⚠️ [TokenStorage Cảnh Báo]: Lỗi xóa token Secure Storage: $e');
    }
  }

  /// Kiểm tra xem đã có token trong máy hay chưa
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static const String _avatarPathKey = 'local_avatar_path';
  String? _inMemoryAvatarPath;

  /// Lưu đường dẫn ảnh đại diện được chọn (khi chưa có API upload trên backend)
  Future<void> saveAvatarPath(String path) async {
    _inMemoryAvatarPath = path;
    try {
      await _storage.write(key: _avatarPathKey, value: path);
      debugPrint('💾 [TokenStorage]: Đã lưu đường dẫn avatar cục bộ: $path');
    } catch (e) {
      debugPrint('⚠️ [TokenStorage Cảnh Báo]: Lỗi lưu avatar vào Secure Storage ($e). Lưu tạm bộ nhớ.');
    }
  }

  /// Lấy đường dẫn ảnh đại diện cục bộ đã lưu
  Future<String?> getAvatarPath() async {
    try {
      final path = await _storage.read(key: _avatarPathKey);
      if (path != null && path.isNotEmpty) {
        return path;
      }
    } catch (e) {
      debugPrint('⚠️ [TokenStorage Cảnh Báo]: Lỗi đọc avatar từ Secure Storage ($e).');
    }
    return _inMemoryAvatarPath;
  }

  /// Xóa ảnh đại diện khi đăng xuất
  Future<void> deleteAvatarPath() async {
    _inMemoryAvatarPath = null;
    try {
      await _storage.delete(key: _avatarPathKey);
    } catch (_) {}
  }
}
