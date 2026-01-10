import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final SharedPreferences _prefs;

  AuthenticatedHttpClient(this._inner, this._prefs);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = _prefs.getString('accessToken');
    
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Ensure Content-Type is set for JSON requests if not already set, 
    // although libraries usually handle this, explicit setting is good for API clients.
    // However, the repositories were setting it manually.
    // We can also make this a "JsonHttpClient" decorator if we wanted to enforce JSON,
    // but for now let's stick to Authentication Aspect.
    
    return _inner.send(request);
  }
}
