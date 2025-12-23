import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/domain/auth/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<UserProfile> call({
    String? name,
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  }) {
    return _repository.updateProfile(
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      userType: userType,
      language: language,
    );
  }
}
