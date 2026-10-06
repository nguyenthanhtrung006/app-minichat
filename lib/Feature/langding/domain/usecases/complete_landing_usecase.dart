import '../repositories/landing_repository.dart';

/// Use case to flag that the user has completed or skipped the landing flow.
class CompleteLandingUseCase {
  final LandingRepository repository;

  CompleteLandingUseCase({required this.repository});

  Future<bool> call() {
    return repository.completeLanding();
  }
}
