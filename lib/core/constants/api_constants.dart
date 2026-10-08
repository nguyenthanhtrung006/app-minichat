/// Định nghĩa các hằng số liên quan đến API theo tài liệu backend Mini Chat
class ApiConstants {
  // Base URL chính thức từ tài liệu API (https://api.trungmobileapp.id.vn)
  static const String baseUrl = 'https://api.trungmobileapp.id.vn';

  // Base URL dự phòng cho môi trường dev local (nếu test trực tiếp trên máy hoặc Cloudflare redirect)
  // - Windows App / Localhost: https://localhost:7136 (hoặc http://localhost:5124)
  // - Android Emulator: https://10.0.2.2:7136
  static const String localBaseUrl = 'https://localhost:7136';

  // Chế độ sử dụng URL: Mặc định ưu tiên baseUrl chính thức theo Docs
  // Nếu bạn đang chạy test nội bộ trên máy có thể bật true
  static const bool useLocalUrl = false;

  /// Lấy Base URL hiện hành
  static String get activeBaseUrl => useLocalUrl ? localBaseUrl : baseUrl;

  // Header chuẩn
  static const String contentType = 'application/json';

  // Các Endpoints xác thực (Auth Endpoints)
  static const String registerEndpoint = '/api/Auth/register';
  static const String loginEndpoint = '/api/Auth/login';
  static const String meEndpoint = '/api/Auth/me';
  static const String avatarEndpoint = '/api/Auth/avatar';
  static const String forgotPasswordEndpoint = '/api/Auth/forgot-password';
  static const String verifyOtpEndpoint = '/api/Auth/verify-otp';
  static const String resetPasswordEndpoint = '/api/Auth/reset-password';
  static const String resendOtpEndpoint = '/api/Auth/resend-otp';
}
