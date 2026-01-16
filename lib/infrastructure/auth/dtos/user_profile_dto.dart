import 'package:quizzy/domain/auth/entities/user_profile.dart';

class UserProfileDto {
  final String id;
  final String name;
  final String username;
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
    required this.username,
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
    if (json.containsKey('userProfileDetails')) {
      final details = json['userProfileDetails'] as Map<String, dynamic>;
      json['name'] = details['name'];
      json['description'] = details['description'];
      json['avatarUrl'] = details['avatarAssetUrl'];
    }

    return UserProfileDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      username: json['username'] as String? ?? json['name'] as String,
      email: json['email'] as String,
      description: json['description'] as String? ?? '',
      userType: json['type'] as String? ?? json['userType'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      theme: _parseTheme(json),
      language: json['language'] as String? ?? 'es',
      gameStreak: json['gameStreak'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      name: name,
      username: username,
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

  static String _parseTheme(Map<String, dynamic> json) {
    if (json['theme'] != null) return json['theme'] as String;
    if (json['preferences'] != null && json['preferences'] is Map) {
      return (json['preferences']['theme'] as String?) ?? 'light';
    }
    return 'light';
  }
}
