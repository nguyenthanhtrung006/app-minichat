import '../../domain/entities/landing_page_data.dart';
import '../../domain/repositories/landing_repository.dart';
import '../datasources/landing_local_datasource.dart';

class LandingRepositoryImpl implements LandingRepository {
  final LandingLocalDataSource localDataSource;

  LandingRepositoryImpl({required this.localDataSource});

  @override
  Future<List<LandingPageData>> getLandingPages() {
    return localDataSource.getLandingPages();
  }

  @override
  Future<bool> completeLanding() {
    return localDataSource.markLandingComplete();
  }

  @override
  Future<bool> isLandingCompleted() {
    return localDataSource.isLandingComplete();
  }
}
