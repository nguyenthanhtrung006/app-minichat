import '../repositories/qr_repository.dart';

class ToggleFlashUseCase {
  final QrRepository repository;

  ToggleFlashUseCase({required this.repository});

  Future<bool> call(bool currentStatus) {
    return repository.toggleFlash(currentStatus);
  }
}
