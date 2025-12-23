import 'package:quizzy/domain/auth/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    String? name,
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
