import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'https://quizzy-backend-1-zpvc.onrender.com/api';
  final paths = [
    'profile',
    'user/profile',
    'users/profile',
    'users/me',
    'user/me',
    'auth/profile',
    'auth/me',
    'user',
    'me'
  ];

  print('Probing backend at $baseUrl for profile endpoints...\n');

  for (final path in paths) {
    var url = Uri.parse('$baseUrl/$path');
    try {
      // Sending a request without token should ideally return 401 if the endpoint exists and is protected.
      // If it returns 404 or the "ENOENT" error (which is 404 from backend's static file handler), it's likely wrong.
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('GET $path -> ${response.statusCode}');
      if (response.statusCode != 404 && !response.body.contains('ENOENT')) {
        print('POSSIBLE HIT: $path');
        print('Body match: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
      } else {
        // print('Miss: $path (${response.statusCode})');
      }
    } catch (e) {
      print('Error probing $path: $e');
    }
  }
}
