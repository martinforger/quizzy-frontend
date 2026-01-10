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
      print('🔐 [AuthenticatedHttpClient] Token: $token');
      request.headers['Authorization'] = 'Bearer $token';
    }

    return _inner.send(request);
  }
}
