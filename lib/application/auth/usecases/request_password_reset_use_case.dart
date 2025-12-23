import 'package:quizzy/domain/auth/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  RequestPasswordResetUseCase(this._repository);

  Future<void> call({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }
}
