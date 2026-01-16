import 'package:quizzy/application/auth/usecases/get_profile_use_case.dart';
import 'package:quizzy/application/auth/usecases/update_password_use_case.dart';
import 'package:quizzy/application/auth/usecases/update_profile_use_case.dart';
import 'package:quizzy/domain/auth/entities/user_profile.dart';

class ProfileController {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;

  ProfileController({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updatePasswordUseCase,
  });

  Future<UserProfile> getProfile() {
    return getProfileUseCase();
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  }) {
    return updateProfileUseCase(
      name: name,
      email: email,
      description: description,
      avatarUrl: avatarUrl,
      userType: userType,
      language: language,
    );
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword, String confirmNewPassword) {
    return updatePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
