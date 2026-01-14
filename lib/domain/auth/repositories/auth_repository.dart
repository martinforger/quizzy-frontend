import 'package:quizzy/domain/auth/entities/user.dart';

abstract class AuthRepository {
  Future<(User, String)> register({
    required String name,
    required String email,
    required String password,
    required String userType,
  });

  Future<String> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  });

  Future<String?> getToken();
}
