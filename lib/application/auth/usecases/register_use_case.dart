import 'package:quizzy/domain/auth/entities/user.dart';
import 'package:quizzy/domain/auth/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<(User, String)> call({
    required String name,
    required String username,
    required String email,
    required String password,
    required String userType,
  }) {
    return _repository.register(
      name: name,
      username: username,
      email: email,
      password: password,
      userType: userType,
    );
  }
}
