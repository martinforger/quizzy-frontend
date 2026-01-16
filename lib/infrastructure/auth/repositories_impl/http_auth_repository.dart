import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/auth/entities/user.dart';
import 'package:quizzy/domain/auth/repositories/auth_repository.dart';
import 'package:quizzy/infrastructure/auth/dtos/user_dto.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpAuthRepository implements AuthRepository {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  HttpAuthRepository({required this.client, required this.sharedPreferences});

  /// Builds URL dynamically using current backend from BackendSettings
  Uri _resolve(String path) => Uri.parse('${BackendSettings.baseUrl}/$path');

  Future<String?> _getToken() async {
    return getToken();
  }

  Future<void> _saveToken(String token) async {
    await sharedPreferences.setString('accessToken', token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString('accessToken');
  }

  Future<void> _deleteToken() async {
    await sharedPreferences.remove('accessToken');
  }

  @override
  Future<(User, String)> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String userType,
  }) async {
    final uri = _resolve('user/register');
    final body = json.encode({
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
    });

    final response = await client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final userDto = UserDto.fromJson(data['user']);
      
      // Attempt to find token in response, otherwise perform login
      String? token = data['accessToken'] as String? ?? data['token'] as String?;
      
      if (token == null) {
        // Auto-login if token is not provided in registration response
        token = await login(username: username, password: password);
      } else {
        await _saveToken(token);
      }
      
      return (userDto.toDomain(), token);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final uri = _resolve('auth/login');
    final body = json.encode({'username': username, 'password': password});

    final response = await client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

    // Accept any 2xx status code as success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      // Support both 'accessToken' (spec) and 'token' (some backends)
      final token = (data['accessToken'] ?? data['token']) as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Login response missing token');
      }
      await _saveToken(token);
      return token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  @override
  Future<void> logout() async {
    final uri = _resolve('auth/logout');

    // Attempt to call the logout endpoint
    try {
      await client
          .post(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5)); // Short timeout for logout
    } catch (e) {
      // Ignore errors (network, 404, etc.) since we want to clear local state anyway
      print('⚠️ [HttpAuthRepository] Logout backend call failed: $e');
    } finally {
      // Always delete local token
      await _deleteToken();
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    final uri = _resolve('auth/password-reset/request');
    final body = json.encode({'email': email});

    final response = await client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

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

    final response = await client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 204) {
      throw Exception('Failed to confirm password reset: ${response.body}');
    }
  }
}
