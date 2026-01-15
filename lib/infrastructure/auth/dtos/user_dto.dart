import 'package:quizzy/domain/auth/entities/user.dart';

class UserDto {
  final String id;
  final String name;
  final String username;
  final String email;
  final String userType;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.userType,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String? ?? json['name'] as String,
      email: json['email'] as String,
      userType: json['userType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  User toDomain() {
    return User(
      id: id,
      name: name,
      username: username,
      email: email,
      userType: userType,
      createdAt: createdAt,
    );
  }
}
