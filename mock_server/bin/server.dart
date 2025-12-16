import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../lib/data.dart';

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 3000;
  final router = Router();

  final List<Map<String, dynamic>> _categories = categories.map((e) => Map<String, dynamic>.from(e)).toList();
  final List<Map<String, dynamic>> _kahoots = seedKahoots.map((e) => Map<String, dynamic>.from(e)).toList();

  // Explore endpoints (epica 6)
  router.get('/explore', (Request req) {
    final query = req.url.queryParameters['q']?.toLowerCase() ?? '';
    final categoriesFilter = (req.url.queryParameters['categories'] ?? '')
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.toLowerCase())
        .toList();

    final items = _kahoots.where((k) {
      final matchesQuery = query.isEmpty ||
          (k['title'] as String? ?? '').toLowerCase().contains(query) ||
          (k['description'] as String? ?? '').toLowerCase().contains(query);
      final cat = (k['category'] as String? ?? '').toLowerCase();
      final matchesCategory = categoriesFilter.isEmpty || categoriesFilter.contains(cat);
      return matchesQuery && matchesCategory;
    }).map(_summaryFromKahoot).toList();

    final response = {
      'data': items,
      'pagination': {
        'page': 1,
        'limit': items.length,
        'totalCount': items.length,
        'totalPages': 1,
      }
    };
    return _json(response);
  });

  router.get('/explore/featured', (Request req) {
    final limit = int.tryParse(req.url.queryParameters['limit'] ?? '') ?? 10;
    final items = _kahoots.take(limit).map(_summaryFromKahoot).toList();
    return _json({'data': items});
  });

  router.get('/explore/categories', (Request req) => _json({'data': _categories}));

  // Kahoots CRUD (epica 2)
  router.get('/kahoots/<id>', (Request req, String id) {
    final match = _kahoots.firstWhere((k) => k['id'] == id, orElse: () => {});
    if (match.isEmpty) return _notFound();
    return _json(match);
  });

  router.post('/kahoots', (Request req) async {
    final body = await req.readAsString();
    final Map<String, dynamic> jsonBody = jsonDecode(body) as Map<String, dynamic>;
    final newId = 'kh-${DateTime.now().millisecondsSinceEpoch}';
    final kahoot = _normalizeKahoot(jsonBody, id: newId, createdAt: DateTime.now().toUtc().toIso8601String());
    _kahoots.add(kahoot);
    return _json(kahoot, status: 201);
  });

  router.put('/kahoots/<id>', (Request req, String id) async {
    final idx = _kahoots.indexWhere((k) => k['id'] == id);
    if (idx == -1) return _notFound();
    final body = await req.readAsString();
    final Map<String, dynamic> jsonBody = jsonDecode(body) as Map<String, dynamic>;
    final updated = _normalizeKahoot(jsonBody, id: id, createdAt: _kahoots[idx]['createdAt'] as String?);
    _kahoots[idx] = updated;
    return _json(updated);
  });

  router.delete('/kahoots/<id>', (Request req, String id) {
    _kahoots.removeWhere((k) => k['id'] == id);
    return Response(204);
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Mock server running on http://localhost:${server.port}');
}

Map<String, dynamic> _summaryFromKahoot(Map<String, dynamic> k) {
  return {
    'id': k['id'],
    'title': k['title'],
    'author': 'Quizzy Mock',
    'category': k['category'],
    'coverImageId': k['coverImageId'],
    'description': k['description'],
    'playCount': k['playCount'] ?? 0,
    'themes': [k['category']],
  };
}

Map<String, dynamic> _normalizeKahoot(
  Map<String, dynamic> body, {
  required String id,
  String? createdAt,
}) {
  final questions = (body['questions'] as List<dynamic>? ?? [])
      .asMap()
      .entries
      .map((entry) {
        final q = entry.value as Map<String, dynamic>;
        final qId = q['id'] as String? ?? 'q-$id-${entry.key}';
        final answers = (q['answers'] as List<dynamic>? ?? [])
            .asMap()
            .entries
            .map((ansEntry) {
              final a = ansEntry.value as Map<String, dynamic>;
              return {
                'id': a['id'] as String? ?? 'a-$qId-${ansEntry.key}',
                'text': a['text'],
                'mediaId': a['mediaId'],
                'isCorrect': a['isCorrect'] == true,
              };
            })
            .toList();
        return {
          'id': qId,
          'text': q['text'],
          'mediaId': q['mediaId'],
          'type': q['type'],
          'timeLimit': q['timeLimit'],
          'points': q['points'],
          'answers': answers,
        };
      })
      .toList();

  return {
    'id': id,
    'title': body['title'],
    'description': body['description'],
    'coverImageId': body['coverImageId'],
    'visibility': body['visibility'],
    'themeId': body['themeId'],
    'authorId': body['authorId'],
    'category': body['category'],
    'status': body['status'],
    'createdAt': createdAt ?? DateTime.now().toUtc().toIso8601String(),
    'playCount': body['playCount'] ?? 0,
    'questions': questions,
  };
}

Response _json(Object data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}

Response _notFound() => Response.notFound(jsonEncode({'message': 'Not Found', 'statusCode': 404}));
