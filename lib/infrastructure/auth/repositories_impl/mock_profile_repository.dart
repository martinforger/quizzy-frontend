import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/domain/auth/repositories/profile_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/mock_data_store.dart';

class MockProfileRepository implements ProfileRepository {
  
  @override
  Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDataStore().currentUser;
  }

  @override
  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final current = MockDataStore().currentUser;
    final updated = current.copyWith(
      name: name,
      email: email,
      description: description,
      userType: userType,
      avatarUrl: avatarUrl,
      language: language,
      updatedAt: DateTime.now(),
    );

    MockDataStore().currentUser = updated;
    return updated;
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate successful password update
  }
}
