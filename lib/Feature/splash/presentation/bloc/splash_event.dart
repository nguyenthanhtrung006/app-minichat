import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the splash screen is first rendered and initialization starts.
class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// Dispatched internally whenever a progress update is received from the use case.
class SplashProgressChanged extends SplashEvent {
  final double progress;

  const SplashProgressChanged(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Dispatched when all initialization steps have completed.
class SplashCompleted extends SplashEvent {
  final bool isAuthenticated;

  const SplashCompleted({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}
