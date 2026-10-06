/// Abstract repository defining the contract for splash/initialization operations.
abstract class SplashRepository {
  /// Emits progress values (0.0 to 1.0) during app bootstrap.
  Stream<double> initializeApp();

  /// Checks if the user is already authenticated or if initial onboarding is needed.
  Future<bool> checkAuthStatus();
}
