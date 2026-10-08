import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';

/// Client mạng trung tâm phụ trách gọi REST API theo chuẩn Docs:
/// - Base URL: https://api.trungmobileapp.id.vn
/// - Headers: Content-Type: application/json
/// - Authorization: Bearer {token}
/// - Tích hợp đầy đủ LOG chi tiết vào Console để dễ theo dõi và debug
class ApiClient {
  final TokenStorage tokenStorage;
  final http.Client _httpClient;

  ApiClient({
    TokenStorage? tokenStorage,
    http.Client? httpClient,
  })  : tokenStorage = tokenStorage ?? TokenStorage.instance,
        _httpClient = httpClient ?? _createDefaultHttpClient();

  /// Khởi tạo HttpClient cho phép self-signed SSL certificate khi chạy dev
  static http.Client _createDefaultHttpClient() {
    try {
      final ioHttpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      return IOClient(ioHttpClient);
    } catch (_) {
      return http.Client();
    }
  }

  /// Tạo Header chuẩn cho request
  Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = false,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': ApiConstants.contentType,
      'Accept': ApiConstants.contentType,
    };

    if (requiresAuth) {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// Gửi POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    return _sendRequest<T>(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
      fromDataJson: fromDataJson,
    );
  }

  /// Gửi GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    return _sendRequest<T>(
      method: 'GET',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      fromDataJson: fromDataJson,
    );
  }

  /// Gửi Multipart Request để upload file (ảnh đại diện) trực tiếp lên Backend
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required File file,
    String fieldName = 'file',
    String method = 'POST',
    bool requiresAuth = true,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    final urlsToTry = <String>[ApiConstants.activeBaseUrl];
    if (!urlsToTry.contains(ApiConstants.localBaseUrl)) {
      urlsToTry.add(ApiConstants.localBaseUrl);
    }

    final token = requiresAuth ? await tokenStorage.getToken() : null;
    http.Response? lastResponse;

    for (final base in urlsToTry) {
      final uri = Uri.parse('$base$endpoint');

      debugPrint('\n🌐 ==================== [API UPLOAD REQUEST] ====================');
      debugPrint('➡️ Method : $method');
      debugPrint('➡️ URL    : $uri');
      debugPrint('➡️ File   : ${file.path}');
      debugPrint('================================================================');

      try {
        final request = http.MultipartRequest(method, uri);
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';

        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
          ),
        );

        final streamed =
            await _httpClient.send(request).timeout(const Duration(seconds: 15));
        lastResponse = await http.Response.fromStream(streamed);

        debugPrint('\n📥 ==================== [API UPLOAD RESPONSE] ====================');
        debugPrint('⬅️ URL         : $uri');
        debugPrint('⬅️ Status Code : ${lastResponse.statusCode}');
        debugPrint('📄 Response Body: ${lastResponse.body}');
        debugPrint('==================================================================');

        if (lastResponse.statusCode != 502 &&
            lastResponse.statusCode != 503 &&
            lastResponse.statusCode != 504) {
          return _processResponse<T>(lastResponse, fromDataJson);
        }
      } catch (e) {
        debugPrint('⚠️ [Upload Lỗi kết nối tới $base]: $e');
      }
    }

    if (lastResponse != null) {
      return _processResponse<T>(lastResponse, fromDataJson);
    }

    throw ApiException('Không thể kết nối đến máy chủ để tải ảnh lên.');
  }

  /// Thực thi HTTP request với logging chi tiết
  Future<ApiResponse<T>> _sendRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    required bool requiresAuth,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    final jsonBody = body != null ? jsonEncode(body) : null;

    final urlsToTry = <String>[ApiConstants.activeBaseUrl];
    if (!urlsToTry.contains(ApiConstants.localBaseUrl)) {
      urlsToTry.add(ApiConstants.localBaseUrl);
    }

    http.Response? lastResponse;
    Exception? lastException;

    for (final base in urlsToTry) {
      final uri = Uri.parse('$base$endpoint');

      // IN LOG REQUEST
      debugPrint('\n🌐 ==================== [API REQUEST] ====================');
      debugPrint('➡️ Method : $method');
      debugPrint('➡️ URL    : $uri');
      debugPrint('➡️ Headers: $headers');
      if (body != null) {
        // Che mật khẩu khi log để bảo mật
        final safeBody = Map<String, dynamic>.from(body);
        if (safeBody.containsKey('password')) {
          safeBody['password'] = '******';
        }
        debugPrint('➡️ Body   : ${jsonEncode(safeBody)}');
      }
      debugPrint('==========================================================');

      try {
        final response = method == 'POST'
            ? await _httpClient
                .post(uri, headers: headers, body: jsonBody)
                .timeout(const Duration(seconds: 8))
            : await _httpClient
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 8));

        lastResponse = response;

        // IN LOG RESPONSE
        debugPrint('\n📥 ==================== [API RESPONSE] ====================');
        debugPrint('⬅️ URL         : $uri');
        debugPrint('⬅️ Status Code : ${response.statusCode}');
        if (response.headers.containsKey('location')) {
          debugPrint('🔄 Location    : ${response.headers['location']}');
        }
        debugPrint('📄 Response Body: ${response.body.isNotEmpty ? response.body : '(trống)'}');
        debugPrint('===========================================================');

        // Trường hợp mã 307: Phân tích & log hướng dẫn chi tiết
        if (response.statusCode == 307) {
          final location = response.headers['location'] ?? 'URL khác';
          debugPrint('⚠️ [CẢNH BÁO 307 REDIRECT]: Máy chủ đang yêu cầu chuyển hướng đến: $location');
          debugPrint('💡 [GỢI Ý KHẮC PHỤC]: Backend ASP.NET Core đang bật app.UseHttpsRedirection(). Hãy tắt dòng này trong Program.cs để Cloudflare chạy bình thường.');
          continue;
        }

        return _processResponse<T>(response, fromDataJson);
      } on SocketException catch (e) {
        lastException = e;
        debugPrint('❌ [LỖI KẾT NỐI MẠNG SocketException]: Không thể kết nối tới $uri ($e)');
        continue;
      } on TimeoutException catch (e) {
        lastException = e;
        debugPrint('⏱️ [LỖI QUÁ THỜI GIAN TimeoutException]: Hết thời gian chờ phản hồi từ $uri');
        continue;
      } catch (e) {
        if (e is ApiException) rethrow;
        lastException = Exception(e.toString());
        debugPrint('❌ [LỖI KHÔNG XÁC ĐỊNH]: $e');
      }
    }

    if (lastResponse != null) {
      return _processResponse<T>(lastResponse, fromDataJson);
    }

    final errorMsg = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc thử lại sau.';
    debugPrint('🚨 [API FATAL ERROR]: $errorMsg (Chi tiết: $lastException)');
    throw ApiException(
      errorMsg,
      details: lastException,
    );
  }

  /// Xử lý HTTP status code theo tài liệu:
  /// - 200 OK: Thành công
  /// - 400 Bad Request: Dữ liệu không hợp lệ
  /// - 401 Unauthorized: Phiên hết hạn / chưa đăng nhập -> Xóa token
  /// - 404 Not Found: Không tìm thấy tài nguyên
  /// - 500 Internal Server Error: Lỗi hệ thống máy chủ
  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(dynamic dataJson)? fromDataJson,
  ) {
    Map<String, dynamic> jsonMap = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          jsonMap = decoded;
        }
      } catch (_) {
        // Body không phải JSON
      }
    }

    switch (response.statusCode) {
      case 200:
        debugPrint('✅ [API SUCCESS 200]: Thao tác thành công.');
        return ApiResponse<T>.fromJson(jsonMap, fromDataJson: fromDataJson);

      case 307:
        final location = response.headers['location'] ?? 'URL nội bộ';
        final msg = 'Máy chủ chuyển hướng 307 đến $location. Vui lòng tắt app.UseHttpsRedirection() ở backend.';
        debugPrint('⚠️ [API 307 ERROR]: $msg');
        throw ApiException(msg, statusCode: 307, details: jsonMap);

      case 400:
        final parsed = ApiResponse<T>.fromJson(jsonMap, fromDataJson: fromDataJson);
        final errMsg = parsed.message.isNotEmpty
            ? parsed.message
            : 'Dữ liệu gửi lên không hợp lệ (400).';
        debugPrint('❌ [API 400 Bad Request]: $errMsg');
        throw ApiException(
          errMsg,
          statusCode: 400,
          details: jsonMap,
        );

      case 401:
        debugPrint('🔒 [API 401 Unauthorized]: Phiên làm việc hết hạn hoặc chưa đăng nhập. Đang xóa token đã lưu...');
        tokenStorage.deleteToken();
        throw UnauthorizedException();

      case 404:
        debugPrint('🔍 [API 404 Not Found]: Không tìm thấy tài nguyên endpoint.');
        throw ApiException(
          'Không tìm thấy tài nguyên (404).',
          statusCode: 404,
        );

      case 500:
        debugPrint('💥 [API 500 Internal Server Error]: Máy chủ backend gặp lỗi xử lý.');
        throw ApiException(
          'Lỗi máy chủ hệ thống (500). Vui lòng thử lại sau.',
          statusCode: 500,
        );

      default:
        final msg = jsonMap['message'] as String? ??
            'Yêu cầu thất bại với mã lỗi ${response.statusCode}';
        debugPrint('⚠️ [API STATUS ${response.statusCode}]: $msg');
        throw ApiException(msg, statusCode: response.statusCode);
    }
  }
}
