import '../entities/user_profile.dart';

abstract class AccountRepository {
  Future<UserProfile> getUserProfile();
}
