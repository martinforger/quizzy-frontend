import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'https://quizzy-backend-1-zpvc.onrender.com/api';
  final paths = [
    'user/profile/password',
    'user/password',
    'auth/password',
    'auth/user/password'
  ];

  print('Probing backend at $baseUrl for password endpoints...\n');

  for (final path in paths) {
    var url = Uri.parse('$baseUrl/$path');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'currentPassword': 'x', 'newPassword': 'y'})
      );
      
      print('PATCH $path -> ${response.statusCode}');
       if (response.statusCode != 404 && !response.body.contains('ENOENT')) {
        print('POSSIBLE HIT: $path');
      }
    } catch (e) {
      print('Error probing $path: $e');
    }
  }
}
