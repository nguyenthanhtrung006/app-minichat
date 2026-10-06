import '../entities/register_params.dart';
import '../repositories/register_repository.dart';

class RegisterUseCase {
  final RegisterRepository repository;

  RegisterUseCase({required this.repository});

  Future<bool> call(RegisterParams params) {
    return repository.register(params);
  }
}
