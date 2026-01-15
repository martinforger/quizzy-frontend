import 'package:quizzy/domain/auth/entities/user.dart';
import 'package:quizzy/domain/auth/repositories/auth_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/mock_data_store.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<(User, String)> register({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = User(
      id: 'mock-user-id',
      name: name,
      email: email,
      userType: userType,
      createdAt: DateTime.now(),
    );
    
    // Update store with registered info
    final store = MockDataStore();
    store.currentUser = store.currentUser.copyWith(
      name: name,
      email: email,
      userType: userType,
    );

    return (user, 'mock-access-token');
  }

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Update store based on login username
    MockDataStore().updateWithUsername(username);

    // Simulate successful login for any input
    return 'mock-access-token';
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
