import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'https://quizzy-backend-1-zpvc.onrender.com/api';
  String? token;

  // 1. Authenticate to get a token
  print('--- 1. Authenticating ---');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'rgdlist', 
        'password': 'Test123456' 
      }), // using credentials from previous postman screenshot user
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      token = data['accessToken'] ?? data['token'];
      print('Login Success. Token: ${token != null ? "Yes" : "No"}');
    } else {
      print('Login Failed: ${response.statusCode} - ${response.body}');
      return;
    }
  } catch (e) {
    print('Error logging in: $e');
    return;
  }

  if (token == null) return;

  // 2. Probe Profile Endpoints with Token
  print('\n--- 2. Probing Profile via GET ---');
  final paths = [
    'user/profile',
    'users/me',
    'auth/me',
    'profile',
    'user/me'
  ];

  for (final path in paths) {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      print('GET $path -> ${response.statusCode}');
      if (response.statusCode == 200) {
        print('SUCCESS HIT: $path');
        print('Body: ${response.body}');
      } else if (response.statusCode != 404 && !response.body.contains('ENOENT')) {
          print('POSSIBLE HIT ($path): ${response.statusCode}');
      }
    } catch (e) {
      print('Error probing $path: $e');
    }
  }
}
