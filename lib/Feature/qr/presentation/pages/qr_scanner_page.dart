import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:minichatapp/l10n/app_localizations.dart';

import '../../data/datasources/qr_datasource.dart';
import '../../data/repositories/qr_repository_impl.dart';
import '../../domain/usecases/get_sample_presets_usecase.dart';
import '../../domain/usecases/pick_gallery_qr_usecase.dart';
import '../../domain/usecases/process_qr_code_usecase.dart';
import '../../domain/usecases/toggle_flash_usecase.dart';
import '../bloc/qr_bloc.dart';
import '../bloc/qr_event.dart';
import '../bloc/qr_state.dart';
import '../widgets/my_qr_code_dialog.dart';
import '../widgets/qr_result_bottom_sheet.dart';
import '../widgets/qr_viewfinder_widget.dart';

/// Clean Architecture & BLoC QR Scanner Screen ("Feature/qr").
class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = QrDatasourceImpl();
        final repository = QrRepositoryImpl(remoteDataSource: dataSource);
        final processQr = ProcessQrCodeUseCase(repository: repository);
        final toggleFlash = ToggleFlashUseCase(repository: repository);
        final pickGallery = PickGalleryQrUseCase(repository: repository);
        final getPresets = GetSamplePresetsUseCase(repository: repository);

        return QrBloc(
          processQrCodeUseCase: processQr,
          toggleFlashUseCase: toggleFlash,
          pickGalleryQrUseCase: pickGallery,
          getSamplePresetsUseCase: getPresets,
        )..add(const QrStarted());
      },
      child: const _QrScannerView(),
    );
  }
}

class _QrScannerView extends StatefulWidget {
  const _QrScannerView();

  @override
  State<_QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<_QrScannerView> {
  int _presetIndex = 0;
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _showResultSheet(BuildContext context, QrSuccessState state) {
    final qrBloc = context.read<QrBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => QrResultBottomSheet(
        data: state.data,
        onScanAgain: () {
          Navigator.of(sheetContext).pop();
        },
      ),
    ).whenComplete(() {
      if (mounted) {
        qrBloc.add(const QrResetScanning());
      }
    });
  }

  Widget _buildCameraError(BuildContext context, MobileScannerException error) {
    final isPermissionDenied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Container(
      color: const Color(0xFF0A0F1D),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPermissionDenied
                    ? Colors.orangeAccent.withValues(alpha: 0.15)
                    : Colors.redAccent.withValues(alpha: 0.15),
                border: Border.all(
                  color: isPermissionDenied
                      ? Colors.orangeAccent.withValues(alpha: 0.4)
                      : Colors.redAccent.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isPermissionDenied
                    ? Icons.no_photography_rounded
                    : Icons.error_outline_rounded,
                color: isPermissionDenied
                    ? Colors.orangeAccent
                    : Colors.redAccent,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPermissionDenied
                  ? 'Quyền Camera chưa được cấp'
                  : 'Không thể kết nối Camera',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isPermissionDenied
                  ? 'Để quét mã QR trực tiếp qua camera, vui lòng cấp quyền truy cập Camera cho MiniChat trong Cài đặt thiết bị.'
                  : (error.errorDetails?.message ?? error.errorCode.message),
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _scannerController.start();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Thử kết nối lại',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007DFE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: BlocConsumer<QrBloc, QrState>(
        listener: (context, state) {
          if (state is QrSuccessState) {
            _showResultSheet(context, state);
          } else if (state is QrErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isFlashOn = state.isFlashOn;
          final isProcessing = state is QrProcessingState;

          return SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Real Hardware Camera Stream
                Positioned.fill(
                  child: MobileScanner(
                    controller: _scannerController,
                    fit: BoxFit.cover,
                    onDetect: (capture) {
                      final bloc = context.read<QrBloc>();
                      if (bloc.state is! QrScanningState) return;

                      final barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final raw = barcode.rawValue ?? barcode.displayValue;
                        if (raw != null && raw.trim().isNotEmpty) {
                          bloc.add(QrCodeScanned(raw.trim()));
                          break;
                        }
                      }
                    },
                    errorBuilder: (context, error) {
                      return _buildCameraError(context, error);
                    },
                  ),
                ),

                // 2. Viewfinder Overlay with Animated Laser & Corner Brackets
                Positioned.fill(
                  child: QrViewfinderWidget(
                    isFlashOn: isFlashOn,
                  ),
                ),

                // 3. Structured Foreground UI Layout
                SafeArea(
                  child: Column(
                    children: [
                      // Top App Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            InkWell(
                              onTap: () => Navigator.of(context).maybePop(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.45),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),

                            // Screen Title
                            Text(
                              lang.scanQr,
                              style: GoogleFonts.nunito(
                                fontSize: 18.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),

                            // Right spacer to keep title perfectly centered
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Instruction Pill Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          lang.qrScanInstruction,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),

                      // Central Area: Viewfinder occupies this space
                      const Spacer(),

                      // Test Sample QR Action Button (allows testing mock codes as well)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context
                                .read<QrBloc>()
                                .add(QrSamplePresetScanned(_presetIndex++));
                          },
                          icon: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFF38BDF8),
                            size: 18,
                          ),
                          label: Text(
                            lang.simulateScan,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                            side: const BorderSide(
                              color: Color(0xFF38BDF8),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bottom 3 Action Buttons (Real Flash, Real Gallery, My QR)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 1. Hardware Flash Toggle Button
                            _buildBottomButton(
                              icon: isFlashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              label: lang.flash,
                              isActive: isFlashOn,
                              onTap: () async {
                                try {
                                  await _scannerController.toggleTorch();
                                  final isOn = _scannerController.value.torchState == TorchState.on;
                                  if (context.mounted) {
                                    context.read<QrBloc>().add(QrFlashStateChanged(isOn));
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Thiết bị không hỗ trợ hoặc không thể bật đèn Flash',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),

                            // 2. Pick and Scan from Gallery Button
                            _buildBottomButton(
                              icon: Icons.photo_library_rounded,
                              label: lang.gallery,
                              isActive: false,
                              onTap: () {
                                context
                                    .read<QrBloc>()
                                    .add(const QrGalleryScanRequested());
                              },
                            ),

                            // 3. My QR Code Dialog Button
                            _buildBottomButton(
                              icon: Icons.qr_code_2_rounded,
                              label: lang.myQrCode,
                              isActive: false,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const MyQrCodeDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // 4. Processing / Loading Overlay
                if (isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF007DFE),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Đang xử lý mã QR...',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFFFBBF24)
                  : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFFBBF24)
                    : Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF0F172A) : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
