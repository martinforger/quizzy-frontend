import 'package:quizzy/application/auth/usecases/confirm_password_reset_use_case.dart';
import 'package:quizzy/application/auth/usecases/login_use_case.dart';
import 'package:quizzy/application/auth/usecases/logout_use_case.dart';
import 'package:quizzy/application/auth/usecases/register_use_case.dart';
import 'package:quizzy/application/auth/usecases/request_password_reset_use_case.dart';
import 'package:quizzy/domain/auth/entities/user.dart';

class AuthController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ConfirmPasswordResetUseCase confirmPasswordResetUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.requestPasswordResetUseCase,
    required this.confirmPasswordResetUseCase,
  });

  Future<String> login(String username, String password) {
    return loginUseCase(username: username, password: password);
  }

  Future<(User, String)> register(String name, String email, String password, String userType) {
    return registerUseCase(
      name: name,
      email: email,
      password: password,
      userType: userType,
    );
  }

  Future<void> logout() {
    return logoutUseCase();
  }

  Future<void> requestPasswordReset(String email) {
    return requestPasswordResetUseCase(email: email);
  }

  Future<void> confirmPasswordReset(String token, String newPassword) {
    return confirmPasswordResetUseCase(resetToken: token, newPassword: newPassword);
  }
}
