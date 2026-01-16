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
    final uri = _resolve('user/profile');

    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Backend wraps response in 'user' object
      final userData = data['user'] != null ? data['user'] : data;
      return UserProfileDto.fromJson(userData).toDomain();
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }

  @override
  Future<UserProfile> getUserById(String id) async {
    final uri = _resolve('user/profile/id/$id');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userData = data['user'] != null ? data['user'] : data;
      return UserProfileDto.fromJson(userData).toDomain();
    } else {
      throw Exception('Failed to get user by id: ${response.body}');
    }
  }

  @override
  Future<UserProfile> getUserByUsername(String username) async {
    final uri = _resolve('user/profile/username/$username');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userData = data['user'] != null ? data['user'] : data;
      return UserProfileDto.fromJson(userData).toDomain();
    } else {
      throw Exception('Failed to get user by username: ${response.body}');
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
    final uri = _resolve('user/profile');

    final bodyMap = <String, dynamic>{};
    if (name != null) bodyMap['name'] = name;
    if (email != null) bodyMap['email'] = email;
    if (description != null) bodyMap['description'] = description;
    // Map avatarUrl to avatarAssetId as per spec
    // Note: If avatarUrl is a URL, this might fail if backend expects an ID.
    // Assuming backend might accept the URL or we need to change how we handle avatars.
    if (avatarUrl != null) bodyMap['avatarAssetId'] = avatarUrl;
    
    // Remove unsupported fields to avoid 400 Bad Request
    // if (userType != null) bodyMap['userType'] = userType;
    // if (language != null) bodyMap['language'] = language;

    final response = await client.patch(
      uri,
      headers: _headers,
      body: json.encode(bodyMap),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userData = data['user'] != null ? data['user'] : data;
      return UserProfileDto.fromJson(userData).toDomain();
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    // According to spec, password update is part of the general profile update
    final uri = _resolve('user/profile');

    final body = json.encode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    });

    final response = await client.patch(uri, headers: _headers, body: body);

    if (response.statusCode == 200) {
      // Success - backend returns the updated user, but we return void here.
      return;
    } else {
      throw Exception('Failed to update password (${response.statusCode}): ${response.body}');
    }
  }
}
