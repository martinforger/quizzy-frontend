import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/domain/auth/repositories/profile_repository.dart';
import 'package:quizzy/infrastructure/auth/dtos/user_profile_dto.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

class HttpProfileRepository implements ProfileRepository {
  final http.Client client;

  HttpProfileRepository({required this.client});

  /// Builds URL dynamically using current backend from BackendSettings
  Uri _resolve(String path) => Uri.parse('${BackendSettings.baseUrl}/$path');

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  @override
  Future<UserProfile> getProfile() async {
    final uri = _resolve('profile');

    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfileDto.fromJson(data).toDomain();
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
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
    final uri = _resolve('profile');

    final bodyMap = <String, dynamic>{};
    if (name != null) bodyMap['name'] = name;
    if (email != null) bodyMap['email'] = email;
    if (description != null) bodyMap['description'] = description;
    if (avatarUrl != null) bodyMap['avatarUrl'] = avatarUrl;
    if (userType != null) bodyMap['userType'] = userType;
    if (language != null) bodyMap['language'] = language;

    final response = await client.patch(
      uri,
      headers: _headers,
      body: json.encode(bodyMap),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfileDto.fromJson(data).toDomain();
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = _resolve('profile/password');

    final body = json.encode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    final response = await client.patch(uri, headers: _headers, body: body);

    if (response.statusCode != 204) {
      throw Exception('Failed to update password: ${response.body}');
    }
  }
}
