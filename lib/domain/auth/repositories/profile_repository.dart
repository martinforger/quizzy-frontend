import 'package:quizzy/domain/auth/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<List<UserProfile>> getAllUsers();

  Future<UserProfile> getProfile();

  Future<UserProfile> getUserById(String id);
  
  Future<UserProfile> getUserByUsername(String username);

  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}
