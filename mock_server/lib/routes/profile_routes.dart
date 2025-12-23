import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ProfileRoutes {
  ProfileRoutes();

  Router get router {
    final router = Router();
    router.get('/', _getProfile);
    router.patch('/', _updateProfile);
    router.patch('/password', _updatePassword);
    return router;
  }

  Future<Response> _getProfile(Request request) async {
    // Check auth header simulation
    if (request.headers['Authorization'] == null) {
       return Response(401, body: json.encode({'message': 'Unauthorized'}), headers: {'content-type': 'application/json'});
    }

    final response = {
      'id': 'uuid-1',
      'name': 'Usuario Mock',
      'email': 'user@example.com',
      'description': 'Descripcion del usuario mock',
      'userType': 'teacher',
      'avatarUrl': 'https://i.pravatar.cc/150?u=uuid-1',
      'theme': 'dark',
      'language': 'es',
      'gameStreak': 12,
      'createdAt': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
    };
    return Response.ok(json.encode(response), headers: {'content-type': 'application/json'});
  }

  Future<Response> _updateProfile(Request request) async {
    if (request.headers['Authorization'] == null) {
       return Response(401, body: json.encode({'message': 'Unauthorized'}), headers: {'content-type': 'application/json'});
    }
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>;

    final response = {
      'id': 'uuid-1',
      'name': body['name'] ?? 'Usuario Mock',
      'email': 'user@example.com',
      'description': body['description'] ?? 'Descripcion del usuario mock',
      'userType': body['userType'] ?? 'teacher',
      'avatarUrl': body['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=uuid-1',
      'theme': 'dark',
      'language': body['language'] ?? 'es',
      'gameStreak': 12,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    return Response.ok(json.encode(response), headers: {'content-type': 'application/json'});
  }

  Future<Response> _updatePassword(Request request) async {
    if (request.headers['Authorization'] == null) {
       return Response(401, body: json.encode({'message': 'Unauthorized'}), headers: {'content-type': 'application/json'});
    }
    final payload = await request.readAsString();
    final body = json.decode(payload) as Map<String, dynamic>;
    
    if (body['currentPassword'] == 'wrong') {
       return Response(401, body: json.encode({'message': 'Incorrect password'}), headers: {'content-type': 'application/json'});
    }
    
    return Response(204);
  }
}
