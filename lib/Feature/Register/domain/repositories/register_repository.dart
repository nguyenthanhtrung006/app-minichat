import '../entities/register_params.dart';

abstract class RegisterRepository {
  Future<bool> register(RegisterParams params);
}
