import '../../domain/entities/qr_code_entity.dart';
import '../../domain/repositories/qr_repository.dart';
import '../datasources/qr_datasource.dart';

class QrRepositoryImpl implements QrRepository {
  final QrDatasource remoteDataSource;
  bool _flashStatus = false;

  QrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<QrCodeEntity> processQrCode(String rawCode) async {
    return await remoteDataSource.parseQrCode(rawCode);
  }

  @override
  Future<QrCodeEntity?> pickAndScanGallery() async {
    return await remoteDataSource.pickFromGallery();
  }

  @override
  Future<bool> toggleFlash(bool currentStatus) async {
    _flashStatus = !currentStatus;
    return _flashStatus;
  }

  @override
  Future<List<QrCodeEntity>> getSamplePresets() async {
    return await remoteDataSource.getPresets();
  }
}
