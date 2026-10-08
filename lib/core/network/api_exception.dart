/// Lớp đại diện cho lỗi trả về từ API hoặc lỗi kết nối mạng
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

/// Lỗi riêng biệt khi phiên đăng nhập hết hạn hoặc chưa đăng nhập (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'])
      : super(statusCode: 401);
}
