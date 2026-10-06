import '../entities/qr_code_entity.dart';
import '../repositories/qr_repository.dart';

class ProcessQrCodeUseCase {
  final QrRepository repository;

  ProcessQrCodeUseCase({required this.repository});

  Future<QrCodeEntity> call(String rawCode) {
    return repository.processQrCode(rawCode);
  }
}
