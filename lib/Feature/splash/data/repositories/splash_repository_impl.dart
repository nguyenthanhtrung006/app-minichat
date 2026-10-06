import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_local_datasource.dart';

/// Concrete implementation of [SplashRepository]
class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;

  SplashRepositoryImpl({required this.localDataSource});

  @override
  Stream<double> initializeApp() {
    return localDataSource.loadInitialData();
  }

  @override
  Future<bool> checkAuthStatus() {
    return localDataSource.hasSavedToken();
  }
}
