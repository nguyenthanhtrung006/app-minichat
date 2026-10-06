import 'package:equatable/equatable.dart';
import '../../domain/entities/qr_code_entity.dart';

abstract class QrState extends Equatable {
  final bool isFlashOn;
  final List<QrCodeEntity> presets;

  const QrState({
    this.isFlashOn = false,
    this.presets = const [],
  });

  @override
  List<Object?> get props => [isFlashOn, presets];
}

class QrInitial extends QrState {
  const QrInitial() : super();
}

class QrScanningState extends QrState {
  const QrScanningState({
    super.isFlashOn,
    super.presets,
  });
}

class QrProcessingState extends QrState {
  const QrProcessingState({
    super.isFlashOn,
    super.presets,
  });
}

class QrSuccessState extends QrState {
  final QrCodeEntity data;

  const QrSuccessState({
    required this.data,
    super.isFlashOn,
    super.presets,
  });

  @override
  List<Object?> get props => [data, isFlashOn, presets];
}

class QrErrorState extends QrState {
  final String errorMessage;

  const QrErrorState({
    required this.errorMessage,
    super.isFlashOn,
    super.presets,
  });

  @override
  List<Object?> get props => [errorMessage, isFlashOn, presets];
}
