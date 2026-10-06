import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_sample_presets_usecase.dart';
import '../../domain/usecases/pick_gallery_qr_usecase.dart';
import '../../domain/usecases/process_qr_code_usecase.dart';
import '../../domain/usecases/toggle_flash_usecase.dart';
import 'qr_event.dart';
import 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final ProcessQrCodeUseCase processQrCodeUseCase;
  final ToggleFlashUseCase toggleFlashUseCase;
  final PickGalleryQrUseCase pickGalleryQrUseCase;
  final GetSamplePresetsUseCase getSamplePresetsUseCase;

  QrBloc({
    required this.processQrCodeUseCase,
    required this.toggleFlashUseCase,
    required this.pickGalleryQrUseCase,
    required this.getSamplePresetsUseCase,
  }) : super(const QrInitial()) {
    on<QrStarted>(_onStarted);
    on<QrCodeScanned>(_onCodeScanned);
    on<QrFlashToggled>(_onFlashToggled);
    on<QrFlashStateChanged>(_onFlashStateChanged);
    on<QrGalleryScanRequested>(_onGalleryScanRequested);
    on<QrResetScanning>(_onResetScanning);
    on<QrSamplePresetScanned>(_onSamplePresetScanned);
  }

  Future<void> _onStarted(QrStarted event, Emitter<QrState> emit) async {
    final presets = await getSamplePresetsUseCase();
    emit(QrScanningState(isFlashOn: false, presets: presets));
  }

  Future<void> _onCodeScanned(QrCodeScanned event, Emitter<QrState> emit) async {
    if (state is QrProcessingState || state is QrSuccessState) return;

    emit(QrProcessingState(isFlashOn: state.isFlashOn, presets: state.presets));
    try {
      final result = await processQrCodeUseCase(event.rawCode);
      emit(QrSuccessState(
        data: result,
        isFlashOn: state.isFlashOn,
        presets: state.presets,
      ));
    } catch (e) {
      emit(QrErrorState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isFlashOn: state.isFlashOn,
        presets: state.presets,
      ));
    }
  }

  Future<void> _onFlashToggled(QrFlashToggled event, Emitter<QrState> emit) async {
    final nextStatus = await toggleFlashUseCase(state.isFlashOn);
    if (state is QrSuccessState) {
      final s = state as QrSuccessState;
      emit(QrSuccessState(data: s.data, isFlashOn: nextStatus, presets: state.presets));
    } else {
      emit(QrScanningState(isFlashOn: nextStatus, presets: state.presets));
    }
  }

  void _onFlashStateChanged(QrFlashStateChanged event, Emitter<QrState> emit) {
    if (state is QrSuccessState) {
      final s = state as QrSuccessState;
      emit(QrSuccessState(data: s.data, isFlashOn: event.isFlashOn, presets: state.presets));
    } else {
      emit(QrScanningState(isFlashOn: event.isFlashOn, presets: state.presets));
    }
  }

  Future<void> _onGalleryScanRequested(
    QrGalleryScanRequested event,
    Emitter<QrState> emit,
  ) async {
    emit(QrProcessingState(isFlashOn: state.isFlashOn, presets: state.presets));
    try {
      final result = await pickGalleryQrUseCase();
      if (result != null) {
        emit(QrSuccessState(
          data: result,
          isFlashOn: state.isFlashOn,
          presets: state.presets,
        ));
      } else {
        // User cancelled image selection, return to scanning state
        emit(QrScanningState(
          isFlashOn: state.isFlashOn,
          presets: state.presets,
        ));
      }
    } catch (e) {
      emit(QrErrorState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isFlashOn: state.isFlashOn,
        presets: state.presets,
      ));
    }
  }

  void _onResetScanning(QrResetScanning event, Emitter<QrState> emit) {
    emit(QrScanningState(isFlashOn: state.isFlashOn, presets: state.presets));
  }

  Future<void> _onSamplePresetScanned(
    QrSamplePresetScanned event,
    Emitter<QrState> emit,
  ) async {
    if (state.presets.isEmpty) return;
    final index = event.index % state.presets.length;
    final item = state.presets[index];

    emit(QrProcessingState(isFlashOn: state.isFlashOn, presets: state.presets));
    await Future.delayed(const Duration(milliseconds: 300));
    emit(QrSuccessState(
      data: item,
      isFlashOn: state.isFlashOn,
      presets: state.presets,
    ));
  }
}
