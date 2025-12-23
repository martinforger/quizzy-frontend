import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/domain/auth/repositories/profile_repository.dart';
import 'package:quizzy/infrastructure/auth/dtos/user_profile_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpProfileRepository implements ProfileRepository {
  final http.Client client;
  final String baseUrl;
  final SharedPreferences sharedPreferences;

  HttpProfileRepository({
    required this.client,
    required this.baseUrl,
    required this.sharedPreferences,
  });

  Uri _resolve(String path) => Uri.parse('$baseUrl/$path');

  Future<String?> _getToken() async {
    return sharedPreferences.getString('accessToken');
  }

  Map<String, String> _authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserProfile> getProfile() async {
    final uri = _resolve('profile');
    final token = await _getToken();
    if (token == null) throw Exception('Unauthorized');

    final response = await client.get(
      uri,
      headers: _authHeaders(token),
    );

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
    String? description,
    String? avatarUrl,
    String? userType,
    String? language,
  }) async {
    final uri = _resolve('profile');
    final token = await _getToken();
    if (token == null) throw Exception('Unauthorized');

    final bodyMap = <String, dynamic>{};
    if (name != null) bodyMap['name'] = name;
    if (description != null) bodyMap['description'] = description;
    if (avatarUrl != null) bodyMap['avatarUrl'] = avatarUrl;
    if (userType != null) bodyMap['userType'] = userType;
    if (language != null) bodyMap['language'] = language;

    final response = await client.patch(
      uri,
      headers: _authHeaders(token),
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
    final token = await _getToken();
    if (token == null) throw Exception('Unauthorized');

    final body = json.encode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    final response = await client.patch(
      uri,
      headers: _authHeaders(token),
      body: body,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update password: ${response.body}');
    }
  }
}
