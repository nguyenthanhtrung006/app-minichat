import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state before initialization begins.
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// State emitted while app is initializing, with current progress (0.0 to 1.0).
class SplashLoading extends SplashState {
  final double progress;
  final String statusText;

  const SplashLoading({
    required this.progress,
    this.statusText = 'Đang tải...',
  });

  @override
  List<Object?> get props => [progress, statusText];
}

/// State emitted when initialization is finished and navigation can proceed.
class SplashSuccess extends SplashState {
  final bool isAuthenticated;

  const SplashSuccess({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}

/// State emitted if initialization failed.
class SplashFailure extends SplashState {
  final String errorMessage;

  const SplashFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
