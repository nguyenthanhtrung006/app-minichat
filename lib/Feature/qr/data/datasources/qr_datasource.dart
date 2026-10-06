import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr_code_model.dart';

abstract class QrDatasource {
  Future<QrCodeModel> parseQrCode(String rawCode);
  Future<QrCodeModel?> pickFromGallery();
  Future<List<QrCodeModel>> getPresets();
}

class QrDatasourceImpl implements QrDatasource {
  final ImagePicker _imagePicker;

  QrDatasourceImpl({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final List<QrCodeModel> _presets = [
    QrCodeModel.fromRawString(
      'minichat://user?name=Hoàng Minh Thảo&phone=0912345678&avatar=https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
    QrCodeModel.fromRawString(
      'minichat://user?name=Trần Đức Long&phone=0988776655&avatar=https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    QrCodeModel.fromRawString(
      'minichat://group?name=CLB Lập trình Mobile&code=DEV-2026',
    ),
    QrCodeModel.fromRawString(
      'https://minichatapp.vn/join/u9834',
    ),
  ];

  @override
  Future<QrCodeModel> parseQrCode(String rawCode) async {
    return QrCodeModel.fromRawString(rawCode);
  }

  @override
  Future<QrCodeModel?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (image == null) {
        // User cancelled image picking
        return null;
      }

      final BarcodeCapture? capture =
          await MobileScannerPlatform.instance.analyzeImage(image.path);

      if (capture == null || capture.barcodes.isEmpty) {
        throw Exception('Không tìm thấy mã QR trong ảnh đã chọn');
      }

      for (final barcode in capture.barcodes) {
        final raw = barcode.rawValue ?? barcode.displayValue;
        if (raw != null && raw.trim().isNotEmpty) {
          return QrCodeModel.fromRawString(raw.trim());
        }
      }

      throw Exception('Không tìm thấy mã QR hợp lệ trong ảnh đã chọn');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Không thể đọc mã QR từ thư viện ảnh: $e');
    }
  }

  @override
  Future<List<QrCodeModel>> getPresets() async {
    return _presets;
  }
}
