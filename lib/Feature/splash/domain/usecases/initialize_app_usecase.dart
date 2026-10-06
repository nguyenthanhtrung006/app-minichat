import '../repositories/splash_repository.dart';

/// Use case responsible for orchestrating app initialization logic.
class InitializeAppUseCase {
  final SplashRepository repository;

  InitializeAppUseCase({required this.repository});

  /// Returns a stream of progress values (0.0 to 1.0).
  Stream<double> call() {
    return repository.initializeApp();
  }

  /// Checks authentication state after initialization completes.
  Future<bool> checkAuthStatus() {
    return repository.checkAuthStatus();
  }
}
