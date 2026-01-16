import 'package:quizzy/domain/auth/entities/user.dart';

class UserDto {
  final String id;
  final String name;
  final String username;
  final String email;
  final String userType;
  final String state;
  final bool isPremium;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.userType,
    required this.state,
    required this.isPremium,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('userProfileDetails')) {
      final details = json['userProfileDetails'] as Map<String, dynamic>;
      json['name'] = details['name'];
    }
    
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      username: json['username'] as String,
      email: json['email'] as String,
      userType: json['type'] as String? ?? json['userType'] as String,
      state: json['state'] as String? ?? 'ACTIVE',
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }

  User toDomain() {
    return User(
      id: id,
      name: name,
      username: username,
      email: email,
      userType: userType,
      state: state,
      isPremium: isPremium,
      createdAt: createdAt,
    );
  }
}
