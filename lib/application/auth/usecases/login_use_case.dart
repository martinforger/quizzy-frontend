import 'package:quizzy/domain/auth/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<String> call({
    required String username,
    required String password,
  }) {
    return _repository.login(
      username: username,
      password: password,
    );
  }
}
