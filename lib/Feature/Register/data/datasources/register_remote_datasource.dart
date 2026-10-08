import 'package:minichatapp/core/network/auth_api_client.dart';
import '../../domain/entities/register_params.dart';

abstract class RegisterRemoteDataSource {
  Future<bool> registerUser(RegisterParams params);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final AuthApiClient authApiClient;

  RegisterRemoteDataSourceImpl({AuthApiClient? authApiClient})
      : authApiClient = authApiClient ?? AuthApiClient();

  @override
  Future<bool> registerUser(RegisterParams params) async {
    // 1. Kiểm tra validation cơ bản trước khi gửi request
    if (params.password != params.confirmPassword) {
      throw Exception('Mật khẩu xác nhận không khớp');
    }

    if (params.password.length < 6) {
      throw Exception('Mật khẩu phải có tối thiểu 6 ký tự');
    }

    // 2. Gọi API đăng ký thật tới https://api.trungmobileapp.id.vn/api/auth/register
    // Token trả về sẽ được tự động lưu vào secure storage
    await authApiClient.register(
      email: params.emailOrPhone,
      password: params.password,
      fullName: params.fullName,
    );

    return true;
  }
}
