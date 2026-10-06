import 'dart:async';

/// Data source interface for splash initialization tasks.
abstract class SplashLocalDataSource {
  /// Simulates or executes app initialization steps, streaming progress values.
  Stream<double> loadInitialData();

  /// Determines if authentication credentials exist locally.
  Future<bool> hasSavedToken();
}

/// Implementation of [SplashLocalDataSource]
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  @override
  Stream<double> loadInitialData() async* {
    // Stage 1: Load configurations and local caches
    yield 0.15;
    await Future.delayed(const Duration(milliseconds: 350));

    // Stage 2: Initialize background services & network cache
    yield 0.40;
    await Future.delayed(const Duration(milliseconds: 400));

    // Stage 3: Load user preferences & theme data
    yield 0.70;
    await Future.delayed(const Duration(milliseconds: 450));

    // Stage 4: Sync state & prepare session
    yield 0.90;
    await Future.delayed(const Duration(milliseconds: 350));

    // Stage 5: Ready
    yield 1.0;
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> hasSavedToken() async {
    // In actual implementation, check SharedPreferences or FlutterSecureStorage
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Default to false so user navigates to landing/login
  }
}
