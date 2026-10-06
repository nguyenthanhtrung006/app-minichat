import '../entities/qr_code_entity.dart';

abstract class QrRepository {
  /// Parse & process a raw scanned QR string into a structured entity
  Future<QrCodeEntity> processQrCode(String rawCode);

  /// Pick an image with QR code from device gallery and decode it
  Future<QrCodeEntity?> pickAndScanGallery();

  /// Toggle camera flashlight on or off
  Future<bool> toggleFlash(bool currentStatus);

  /// Sample demo QR items for testing scanning functionality
  Future<List<QrCodeEntity>> getSamplePresets();
}
