import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';
import 'api_exception.dart';
import '../../Feature/Login/data/models/auth_response_model.dart';
import '../../Feature/Login/data/models/user_model.dart';

/// [AuthApiClient] - Service quản lý tất cả thao tác Gọi API Xác thực (Auth).
/// Thiết kế giao diện tập trung, rõ ràng (Query / Mutation style) giúp gọi API dễ dàng như GraphQL:
/// - login(...) -> POST /api/auth/login
/// - register(...) -> POST /api/auth/register
/// - getMe() -> GET /api/auth/me
/// - logout() -> Xóa Token lưu trong máy
class AuthApiClient {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthApiClient({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : apiClient = apiClient ?? ApiClient(),
        tokenStorage = tokenStorage ?? TokenStorage.instance;

  /// 2.2. Đăng nhập tài khoản (Login)
  /// - Endpoint: /api/auth/login
  /// - Method: POST
  /// - Body: { "email": email, "password": password }
  /// - Thành công: Tự động lưu Token vào flutter_secure_storage và trả về AuthResponseModel
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post<AuthResponseModel>(
      ApiConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
      fromDataJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      // Lưu Access Token bảo mật theo khuyến nghị Docs 4.1
      await tokenStorage.saveToken(response.data!.token);
      return response.data!;
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Đăng nhập không thành công',
    );
  }

  /// 2.1. Đăng ký tài khoản mới (Register)
  /// - Endpoint: /api/auth/register
  /// - Method: POST
  /// - Body: { "email": email, "password": password, "fullName": fullName }
  /// - Thành công: Hệ thống tự động trả về Token, tự động lưu token và trả về AuthResponseModel
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await apiClient.post<AuthResponseModel>(
      ApiConstants.registerEndpoint,
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
      requiresAuth: false,
      fromDataJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      // Lưu token vào storage để tự động đăng nhập luôn
      await tokenStorage.saveToken(response.data!.token);
      return response.data!;
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Đăng ký tài khoản không thành công',
    );
  }

  /// 2.3. Lấy thông tin cá nhân của người dùng hiện tại (Get Me)
  /// - Endpoint: /api/auth/me
  /// - Method: GET
  /// - Header: Authorization: Bearer {access_token}
  /// - Dùng khi mở lại app để kiểm tra phiên đăng nhập còn hiệu lực hay không.
  Future<UserModel> getMe() async {
    final response = await apiClient.get<UserModel>(
      ApiConstants.meEndpoint,
      requiresAuth: true,
      fromDataJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Không thể lấy thông tin người dùng',
    );
  }

  /// Đăng xuất: Xóa JWT Token và thông tin đã lưu trong máy
  Future<void> logout() async {
    await tokenStorage.deleteToken();
    await tokenStorage.deleteAvatarPath();
  }

  /// Upload ảnh đại diện trực tiếp lên Database thông qua Backend API
  /// Gửi multipart request với file ảnh và Bearer Token xác thực
  Future<String?> uploadAvatar(File imageFile) async {
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ [uploadAvatar]: Không tìm thấy Token! Người dùng chưa đăng nhập.');
      throw ApiException('Chưa đăng nhập hoặc phiên đã hết hạn. Vui lòng đăng nhập lại.');
    }

    try {
      final response = await apiClient.uploadFile<Map<String, dynamic>>(
        ApiConstants.avatarEndpoint,
        file: imageFile,
        fieldName: 'file',
        requiresAuth: true,
        fromDataJson: (json) {
          if (json is Map<String, dynamic>) return json;
          return {'url': json.toString()};
        },
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final url = data['avatarUrl']?.toString() ??
            data['url']?.toString() ??
            (data['data'] is Map ? data['data']['avatarUrl']?.toString() : null);
        debugPrint('🎉 [uploadAvatar]: Tải ảnh lên database thành công: $url');
        return url;
      } else {
        throw ApiException(
          response.message.isNotEmpty
              ? response.message
              : 'Tải ảnh đại diện không thành công',
        );
      }
    } catch (e) {
      debugPrint('❌ [uploadAvatar]: Lỗi tải ảnh lên server ($e).');
      rethrow;
    }
  }

  /// 2.5. Gửi mã OTP xác thực khi quên mật khẩu (Forgot Password)
  /// - Endpoint: /api/auth/forgot-password
  /// - Method: POST
  /// - Body: { "email": email }
  Future<String> forgotPassword({required String email}) async {
    final response = await apiClient.post<dynamic>(
      ApiConstants.forgotPasswordEndpoint,
      body: {
        'email': email.trim(),
      },
      requiresAuth: false,
    );

    if (response.success) {
      return response.message.isNotEmpty
          ? response.message
          : 'Mã xác thực OTP đã được gửi về email của bạn.';
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Không thể gửi mã xác nhận',
    );
  }

  /// 2.7. Xác thực mã OTP (Verify OTP)
  /// - Endpoint: /api/auth/verify-otp
  /// - Method: POST
  /// - Body: { "email": email, "otp": otp }
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiClient.post<dynamic>(
      ApiConstants.verifyOtpEndpoint,
      body: {
        'email': email.trim(),
        'otp': otp.trim(),
      },
      requiresAuth: false,
    );

    if (response.success) {
      return response.message.isNotEmpty
          ? response.message
          : 'Xác thực mã OTP thành công.';
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Mã OTP không chính xác.',
    );
  }

  /// 2.8. Gửi lại mã OTP (Resend OTP - Cooldown 60s)
  /// - Endpoint: /api/auth/resend-otp
  /// - Method: POST
  /// - Body: { "email": email }
  Future<String> resendOtp({required String email}) async {
    final response = await apiClient.post<dynamic>(
      ApiConstants.resendOtpEndpoint,
      body: {
        'email': email.trim(),
      },
      requiresAuth: false,
    );

    if (response.success) {
      return response.message.isNotEmpty
          ? response.message
          : 'Mã xác thực OTP đã được gửi về email của bạn. Vui lòng kiểm tra hộp thư!';
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Không thể gửi lại mã OTP',
    );
  }

  /// 2.9. Đặt lại mật khẩu mới (Reset Password)
  /// - Endpoint: /api/auth/reset-password
  /// - Method: POST
  /// - Body: { "email": email, "otp": otp, "newPassword": newPassword, "confirmPassword": confirmPassword }
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    String? confirmPassword,
  }) async {
    final response = await apiClient.post<dynamic>(
      ApiConstants.resetPasswordEndpoint,
      body: {
        'email': email.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword,
        'confirmPassword': confirmPassword ?? newPassword,
      },
      requiresAuth: false,
    );

    if (response.success) {
      return response.message.isNotEmpty
          ? response.message
          : 'Đặt lại mật khẩu thành công!';
    }

    throw ApiException(
      response.message.isNotEmpty
          ? response.message
          : 'Đặt lại mật khẩu không thành công.',
    );
  }
}
