import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lớp quản lý lưu trữ JWT Token an toàn theo khuyến nghị mục 4.1 của Docs:
/// "Flutter: Sử dụng flutter_secure_storage thay vì shared_preferences thông thường để bảo mật token."
/// Tích hợp cơ chế fallback bộ nhớ tạm để không bao giờ bị lỗi MissingPluginException khi Hot Reload.
class TokenStorage {
  static const String _tokenKey = 'jwt_access_token';
  static const String _userEmailKey = 'logged_in_user_email';
  static const String _userIdKey = 'logged_in_user_id';
  final FlutterSecureStorage _storage;

  // Bộ nhớ đệm RAM dự phòng (giữ token ngay cả khi plugin native chưa được rebuild)
  String? _inMemoryToken;
  String? _inMemoryEmail;
  String? _inMemoryUserId;

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

  /// Lưu thông tin định danh người dùng (Email & UserId)
  Future<void> saveUserInfo({String? email, String? userId}) async {
    if (email != null && email.isNotEmpty) {
      _inMemoryEmail = email.toLowerCase().trim();
      try {
        await _storage.write(key: _userEmailKey, value: _inMemoryEmail!);
      } catch (_) {}
    }
    if (userId != null && userId.isNotEmpty) {
      _inMemoryUserId = userId.trim();
      try {
        await _storage.write(key: _userIdKey, value: _inMemoryUserId!);
      } catch (_) {}
    }
  }

  /// Lấy Email của người dùng hiện tại (ưu tiên cache -> Secure Storage -> giải mã từ JWT Token)
  Future<String?> getUserEmail() async {
    if (_inMemoryEmail != null && _inMemoryEmail!.isNotEmpty) {
      return _inMemoryEmail;
    }
    try {
      final saved = await _storage.read(key: _userEmailKey);
      if (saved != null && saved.isNotEmpty) {
        _inMemoryEmail = saved.toLowerCase().trim();
        return _inMemoryEmail;
      }
    } catch (_) {}

    // Fallback: Trích xuất trực tiếp từ JWT Payload
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      final emailFromToken = parseEmailFromJwt(token);
      if (emailFromToken != null && emailFromToken.isNotEmpty) {
        _inMemoryEmail = emailFromToken.toLowerCase().trim();
        return _inMemoryEmail;
      }
    }
    return null;
  }

  /// Lấy User ID của người dùng hiện tại (ưu tiên cache -> Secure Storage -> giải mã từ JWT Token)
  Future<String?> getUserId() async {
    if (_inMemoryUserId != null && _inMemoryUserId!.isNotEmpty) {
      return _inMemoryUserId;
    }
    try {
      final saved = await _storage.read(key: _userIdKey);
      if (saved != null && saved.isNotEmpty) {
        _inMemoryUserId = saved.trim();
        return _inMemoryUserId;
      }
    } catch (_) {}

    // Fallback: Trích xuất trực tiếp từ JWT Payload
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      final idFromToken = parseUserIdFromJwt(token);
      if (idFromToken != null && idFromToken.isNotEmpty) {
        _inMemoryUserId = idFromToken.trim();
        return _inMemoryUserId;
      }
    }
    return null;
  }

  /// Giải mã JWT Payload
  static Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        var payload = parts[1];
        while (payload.length % 4 != 0) {
          payload += '=';
        }
        final decoded = utf8.decode(base64Url.decode(payload));
        final map = jsonDecode(decoded);
        if (map is Map<String, dynamic>) return map;
        if (map is Map) return Map<String, dynamic>.from(map);
      }
    } catch (_) {}
    return null;
  }

  /// Trích xuất User ID từ JWT Token
  static String? parseUserIdFromJwt(String token) {
    final map = decodeJwtPayload(token);
    if (map == null) return null;
    return map['nameid']?.toString() ??
        map['sub']?.toString() ??
        map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']?.toString() ??
        map['id']?.toString();
  }

  /// Trích xuất Email từ JWT Token
  static String? parseEmailFromJwt(String token) {
    final map = decodeJwtPayload(token);
    if (map == null) return null;
    return map['email']?.toString() ??
        map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']?.toString() ??
        map['unique_name']?.toString();
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
    _inMemoryEmail = null;
    _inMemoryUserId = null;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userIdKey);
      debugPrint('🗑️ [TokenStorage]: Đã xóa token và thông tin phiên khỏi Secure Storage.');
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
