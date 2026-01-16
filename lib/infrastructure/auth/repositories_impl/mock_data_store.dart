import 'package:quizzy/domain/auth/entities/user_profile.dart';

class MockDataStore {
  static final MockDataStore _instance = MockDataStore._internal();
  factory MockDataStore() => _instance;
  MockDataStore._internal();

  UserProfile currentUser = UserProfile(
    id: 'mock-user-id',
    name: 'Carlos',
    username: 'carlos123',
    email: 'carlos@example.com',
    description: 'Amante de los quizzes y la tecnología.',
    userType: 'Estudiante',
    state: 'ACTIVE',
    isPremium: false,
    avatarUrl: 'https://i.pravatar.cc/150?u=carlos',
    theme: 'light',
    language: 'es',
    gameStreak: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
  );

  void updateWithIdentifier(String identifier) {
    // Generar datos basados en el identificador (usuario o email)
    final namePart = identifier.contains('@') 
        ? identifier.split('@').first 
        : identifier;
    
    // Capitalizar
    final name = namePart.isEmpty ? 'User' : (namePart[0].toUpperCase() + namePart.substring(1));
    
    currentUser = UserProfile(
      id: 'mock-user-$namePart',
      name: name,
      username: identifier.contains('@') ? namePart : identifier,
      email: identifier.contains('@') ? identifier : '$namePart@example.com',
      description: 'Perfil simulado para $name',
      userType: 'Estudiante',
      state: 'ACTIVE',
      isPremium: false,
      avatarUrl: 'https://i.pravatar.cc/150?u=$namePart', // Generates deterministic avatar
      theme: 'light',
      language: 'es',
      gameStreak: 0,
      createdAt: DateTime.now(),
    );
  }
}
