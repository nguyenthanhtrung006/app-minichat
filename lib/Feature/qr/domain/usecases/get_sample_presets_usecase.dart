import '../entities/qr_code_entity.dart';
import '../repositories/qr_repository.dart';

class GetSamplePresetsUseCase {
  final QrRepository repository;

  GetSamplePresetsUseCase({required this.repository});

  Future<List<QrCodeEntity>> call() {
    return repository.getSamplePresets();
  }
}
