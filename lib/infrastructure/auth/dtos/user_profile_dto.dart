import 'package:quizzy/domain/auth/entities/user_profile.dart';

class UserProfileDto {
  final String id;
  final String name;
  final String email;
  final String description;
  final String userType;
  final String avatarUrl;
  final String theme;
  final String language;
  final int gameStreak;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.userType,
    required this.avatarUrl,
    required this.theme,
    required this.language,
    required this.gameStreak,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      description: json['description'] as String? ?? '',
      userType: json['userType'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      theme: json['theme'] as String? ?? 'light',
      language: json['language'] as String? ?? 'es',
      gameStreak: json['gameStreak'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      description: description,
      userType: userType,
      avatarUrl: avatarUrl,
      theme: theme,
      language: language,
      gameStreak: gameStreak,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
