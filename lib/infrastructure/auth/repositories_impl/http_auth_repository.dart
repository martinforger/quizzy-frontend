import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/auth/entities/user.dart';
import 'package:quizzy/domain/auth/repositories/auth_repository.dart';
import 'package:quizzy/infrastructure/auth/dtos/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpAuthRepository implements AuthRepository {
  final http.Client client;
  final String baseUrl;
  final SharedPreferences sharedPreferences;

  HttpAuthRepository({
    required this.client,
    required this.baseUrl,
    required this.sharedPreferences,
  });

  Uri _resolve(String path) => Uri.parse('$baseUrl/$path');

  Future<String?> _getToken() async {
    return sharedPreferences.getString('accessToken');
  }

  Future<void> _saveToken(String token) async {
    await sharedPreferences.setString('accessToken', token);
  }

  Future<void> _deleteToken() async {
    await sharedPreferences.remove('accessToken');
  }

  @override
  Future<(User, String)> register({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    final uri = _resolve('auth/register');
    final body = json.encode({
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
    });

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final userDto = UserDto.fromJson(data['user']);
      final token = data['accessToken'] as String;
      await _saveToken(token);
      return (userDto.toDomain(), token);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = _resolve('auth/login');
    final body = json.encode({
      'email': email,
      'password': password,
    });

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['accessToken'] as String;
      await _saveToken(token);
      return token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  @override
  Future<void> logout() async {
    final uri = _resolve('auth/logout');
    // Using the injected client which should be an AuthenticatedHttpClient (or similar)
    // that automatically adds the Authorization header if a token exists.
    
    // We try to call the logout endpoint
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    // Regardless of server response (204 or 401), we clear local token
    if (response.statusCode == 204 || response.statusCode == 401) {
      await _deleteToken();
    } else {
      // If server error, we might still want to delete token locally, 
      // but let's stick to the spec which says throw exception? 
      // Actually, usually logout should always clear local state.
      // But adhering to previous logic:
      throw Exception('Failed to logout: ${response.body}');
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    final uri = _resolve('auth/password-reset/request');
    final body = json.encode({'email': email});

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 204) {
      throw Exception('Failed to request password reset: ${response.body}');
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    final uri = _resolve('auth/password-reset/confirm');
    final body = json.encode({
      'resetToken': resetToken,
      'newPassword': newPassword,
    });

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 204) {
      throw Exception('Failed to confirm password reset: ${response.body}');
    }
  }
}
