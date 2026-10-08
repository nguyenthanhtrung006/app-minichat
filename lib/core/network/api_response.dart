/// Lớp chuẩn hóa kết quả phản hồi từ API theo mục 1.1 trong Docs:
/// {
///   "success": true,
///   "message": "Thông báo kết quả thao tác",
///   "data": { ... }
/// }
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  /// Parse dữ liệu JSON trả về từ Server
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic dataJson)? fromDataJson,
  }) {
    // 1. Kiểm tra trường hợp chuẩn: { success, message, data }
    if (json.containsKey('success')) {
      final isSuccess = json['success'] as bool? ?? false;
      final msg = json['message'] as String? ?? '';
      final rawData = json['data'];

      return ApiResponse<T>(
        success: isSuccess,
        message: msg,
        data: (rawData != null && fromDataJson != null)
            ? fromDataJson(rawData)
            : null,
      );
    }

    // 2. Kiểm tra trường hợp lỗi Validate do ASP.NET Core sinh ra:
    // { "title": "...", "errors": { "Password": ["..."] } }
    if (json.containsKey('errors') && json['errors'] is Map) {
      final errorsMap = json['errors'] as Map<String, dynamic>;
      final errorMessages = <String>[];
      errorsMap.forEach((field, errors) {
        if (errors is List && errors.isNotEmpty) {
          errorMessages.add('${errors.first}');
        } else if (errors is String) {
          errorMessages.add(errors);
        }
      });

      return ApiResponse<T>(
        success: false,
        message: errorMessages.isNotEmpty
            ? errorMessages.join('\n')
            : (json['title'] as String? ?? 'Dữ liệu gửi lên không hợp lệ'),
        data: null,
      );
    }

    // 3. Dự phòng cho các định dạng khác
    return ApiResponse<T>(
      success: false,
      message: json['message'] as String? ??
          json['title'] as String? ??
          'Phản hồi không xác định từ máy chủ',
      data: null,
    );
  }
}
