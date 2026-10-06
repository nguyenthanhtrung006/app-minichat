import '../entities/landing_page_data.dart';
import '../repositories/landing_repository.dart';

/// Use case to retrieve all onboarding slides.
class GetLandingPagesUseCase {
  final LandingRepository repository;

  GetLandingPagesUseCase({required this.repository});

  Future<List<LandingPageData>> call() {
    return repository.getLandingPages();
  }
}
