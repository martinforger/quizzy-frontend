import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rutas de autenticacion simulada.
class AuthRoutes {
  Router get router {
    final router = Router();
    router.post('/login', _login);
    return router;
  }

  Future<Response> _login(Request request) async {
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>? ?? {};
    final email = body['email'] ?? 'user@example.com';

    final response = {
      'accessToken': 'mock-token-123',
      'user': {
        'id': 'user-1',
        'email': email,
        'name': 'Mock User',
        'userType': 'teacher',
      },
    };
    return Response.ok(json.encode(response), headers: {'content-type': 'application/json'});
  }
}
