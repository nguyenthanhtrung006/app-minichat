import '../entities/user_profile.dart';
import '../repositories/account_repository.dart';

class GetUserProfileUseCase {
  final AccountRepository repository;

  const GetUserProfileUseCase({required this.repository});

  Future<UserProfile> call() async {
    return await repository.getUserProfile();
  }
}
