import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/domain/auth/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfile _mockProfile = UserProfile(
    id: 'mock-user-id',
    name: 'Mock User',
    email: 'user@example.com',
    description: 'This is a mock profile description.',
    userType: 'student',
    avatarUrl: 'https://i.pravatar.cc/150?u=mock',
    theme: 'light',
    language: 'es',
    gameStreak: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
  );

  @override
  Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProfile;
  }

  @override
  Future<UserProfile> updateProfile({
    String? name,
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _mockProfile = UserProfile(
      id: _mockProfile.id,
      name: name ?? _mockProfile.name,
      email: _mockProfile.email,
      description: description ?? _mockProfile.description,
      userType: userType ?? _mockProfile.userType,
      avatarUrl: avatarUrl ?? _mockProfile.avatarUrl,
      theme: _mockProfile.theme,
      language: language ?? _mockProfile.language,
      gameStreak: _mockProfile.gameStreak,
      createdAt: _mockProfile.createdAt,
      updatedAt: DateTime.now(),
    );

    return _mockProfile;
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
