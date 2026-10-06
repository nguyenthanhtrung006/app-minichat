import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class QrStarted extends QrEvent {
  const QrStarted();
}

class QrCodeScanned extends QrEvent {
  final String rawCode;

  const QrCodeScanned(this.rawCode);

  @override
  List<Object?> get props => [rawCode];
}

class QrFlashToggled extends QrEvent {
  const QrFlashToggled();
}

class QrFlashStateChanged extends QrEvent {
  final bool isFlashOn;
  const QrFlashStateChanged(this.isFlashOn);

  @override
  List<Object?> get props => [isFlashOn];
}

class QrGalleryScanRequested extends QrEvent {
  const QrGalleryScanRequested();
}

class QrResetScanning extends QrEvent {
  const QrResetScanning();
}

class QrSamplePresetScanned extends QrEvent {
  final int index;

  const QrSamplePresetScanned(this.index);

  @override
  List<Object?> get props => [index];
}
