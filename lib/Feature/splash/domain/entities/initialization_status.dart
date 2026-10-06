import 'package:equatable/equatable.dart';

/// Represents the status of the app initialization during splash screen.
class InitializationStatus extends Equatable {
  final double progress;
  final bool isCompleted;
  final bool isAuthenticated;
  final String? message;

  const InitializationStatus({
    required this.progress,
    required this.isCompleted,
    required this.isAuthenticated,
    this.message,
  });

  @override
  List<Object?> get props => [progress, isCompleted, isAuthenticated, message];
}
