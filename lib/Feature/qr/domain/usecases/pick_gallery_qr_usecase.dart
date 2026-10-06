import '../entities/qr_code_entity.dart';
import '../repositories/qr_repository.dart';

class PickGalleryQrUseCase {
  final QrRepository repository;

  PickGalleryQrUseCase({required this.repository});

  Future<QrCodeEntity?> call() {
    return repository.pickAndScanGallery();
  }
}
