import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rutas de autenticacion simulada.
class AuthRoutes {
  Router get router {
    final router = Router();
    router.post('/register', _register);
    router.post('/login', _login);
    router.post('/logout', _logout);
    router.post('/password-reset/request', _passwordResetRequest);
    router.post('/password-reset/confirm', _passwordResetConfirm);
    return router;
  }

  Future<Response> _register(Request request) async {
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>;
    
    // Validation simulation
    if (body['email'] == 'exists@example.com') {
       return Response(400, body: json.encode({'message': 'Email already exists'}), headers: {'content-type': 'application/json'});
    }

    final response = {
      'user': {
        'id': 'uuid-nuevo-${DateTime.now().millisecondsSinceEpoch}',
        'name': body['name'],
        'email': body['email'],
        'userType': body['userType'],
        'createdAt': DateTime.now().toIso8601String(),
      },
      'accessToken': 'jwt.token.string.mock',
    };
    return Response(201, body: json.encode(response), headers: {'content-type': 'application/json'});
  }

  Future<Response> _login(Request request) async {
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>;
    
    if (body['email'] == 'error@example.com') {
       return Response(401, body: json.encode({'message': 'Invalid credentials'}), headers: {'content-type': 'application/json'});
    }

    final response = {
      'accessToken': 'mock-token-123',
    };
    return Response.ok(json.encode(response), headers: {'content-type': 'application/json'});
  }

  Future<Response> _logout(Request request) async {
    return Response(204);
  }

  Future<Response> _passwordResetRequest(Request request) async {
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>;
    if (body['email'] == null || !body['email'].toString().contains('@')) {
       return Response(400, body: json.encode({'message': 'Invalid email'}), headers: {'content-type': 'application/json'});
    }
    return Response(204);
  }

  Future<Response> _passwordResetConfirm(Request request) async {
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>;
    if (body['resetToken'] == 'invalid') {
       return Response(400, body: json.encode({'message': 'Invalid token'}), headers: {'content-type': 'application/json'});
    }
    return Response(204);
  }
}
