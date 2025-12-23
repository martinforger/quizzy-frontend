import 'package:quizzy/domain/auth/repositories/auth_repository.dart';

class ConfirmPasswordResetUseCase {
  final AuthRepository _repository;

  ConfirmPasswordResetUseCase(this._repository);

  Future<void> call({
    required String resetToken,
    required String newPassword,
  }) {
    return _repository.confirmPasswordReset(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }
}
