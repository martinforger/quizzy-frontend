import 'package:quizzy/domain/auth/entities/user_profile.dart';

class MockDataStore {
  static final MockDataStore _instance = MockDataStore._internal();
  factory MockDataStore() => _instance;
  MockDataStore._internal();

  UserProfile currentUser = UserProfile(
    id: 'mock-user-id',
    name: 'Carlos',
    email: 'carlos@example.com',
    description: 'Amante de los quizzes y la tecnología.',
    userType: 'Estudiante',
    avatarUrl: 'https://i.pravatar.cc/150?u=carlos',
    theme: 'light',
    language: 'es',
    gameStreak: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
  );

  void updateWithUsername(String username) {
    // Generar datos basados en el username para simular
    final namePart = username.trim().isEmpty ? 'user' : username.trim();
    // Capitalizar
    final name = namePart[0].toUpperCase() + namePart.substring(1);
    
    currentUser = UserProfile(
      id: 'mock-user-$namePart',
      name: name,
      email: '$namePart@example.com',
      description: 'Perfil simulado para $name',
      userType: 'Estudiante',
      avatarUrl: 'https://i.pravatar.cc/150?u=$namePart', // Generates deterministic avatar
      theme: 'light',
      language: 'es',
      gameStreak: 0,
      createdAt: DateTime.now(),
    );
  }
}
