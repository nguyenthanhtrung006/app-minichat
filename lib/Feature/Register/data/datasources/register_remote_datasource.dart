import '../../domain/entities/register_params.dart';

abstract class RegisterRemoteDataSource {
  Future<bool> registerUser(RegisterParams params);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  @override
  Future<bool> registerUser(RegisterParams params) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (params.password != params.confirmPassword) {
      throw Exception('Mật khẩu xác nhận không khớp');
    }

    if (params.password.length < 6) {
      throw Exception('Mật khẩu phải có tối thiểu 6 ký tự');
    }

    return true;
  }
}
