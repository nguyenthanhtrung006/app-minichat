import '../entities/landing_page_data.dart';

/// Abstract contract for landing/onboarding data and state handling.
abstract class LandingRepository {
  /// Fetches all landing pages data.
  Future<List<LandingPageData>> getLandingPages();

  /// Marks the landing flow as completed.
  Future<bool> completeLanding();

  /// Checks if the landing flow has previously been completed.
  Future<bool> isLandingCompleted();
}
