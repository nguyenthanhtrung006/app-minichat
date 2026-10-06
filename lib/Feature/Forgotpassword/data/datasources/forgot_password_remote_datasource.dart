abstract class ForgotPasswordRemoteDataSource {
  Future<bool> sendResetCode(String emailOrPhone);
}

class ForgotPasswordRemoteDataSourceImpl implements ForgotPasswordRemoteDataSource {
  @override
  Future<bool> sendResetCode(String emailOrPhone) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (emailOrPhone.trim().isEmpty) {
      throw Exception('Vui lòng nhập email hoặc số điện thoại');
    }

    return true;
  }
}
