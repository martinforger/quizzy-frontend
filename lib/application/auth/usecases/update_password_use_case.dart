import 'package:quizzy/domain/auth/repositories/profile_repository.dart';

class UpdatePasswordUseCase {
  final ProfileRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
