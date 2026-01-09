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

  // --- Library Endpoints (H7.1 - H7.6) ---

  final Set<String> _userFavorites = {'kh-planet-earth'}; // Mock initial favorite
  
  // Create copies of kahoots for progress/completed to act as separate entities with extra fields
  final List<Map<String, dynamic>> _userInProgress = _kahoots.isNotEmpty 
      ? [{
         ..._kahoots.firstWhere((k) => k['id'] == 'kh-planet-earth', orElse: () => _kahoots.first),
         'gameId': 'game-progress-1',
         'gameType': 'singleplayer',
        }]
      : [];

  final List<Map<String, dynamic>> _userCompleted = _kahoots.length > 1
      ? [{
         ..._kahoots.firstWhere((k) => k['id'] == 'kh-world-history', orElse: () => _kahoots.last),
         'gameId': 'game-completed-1',
         'gameType': 'multiplayer',
        }]
      : [];

  Map<String, dynamic> _paginateAndFilter(
      List<Map<String, dynamic>> source, Request req) {
    final params = req.url.queryParameters;
    final page = int.tryParse(params['page'] ?? '1') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
    final q = (params['q'] ?? '').toLowerCase();
    final status = params['status'] ?? 'all';
    final visibility = params['visibility'] ?? 'all';
    
    // Handling categories as list 
    final categories = req.url.queryParametersAll['categories[]'] ?? 
                       req.url.queryParametersAll['categories'];
    
    var filtered = source.where((item) {
      if (q.isNotEmpty) {
        final title = (item['title'] as String? ?? '').toLowerCase();
        final desc = (item['description'] as String? ?? '').toLowerCase();
        if (!title.contains(q) && !desc.contains(q)) return false;
      }
      if (status != 'all' && item['status'] != status) return false;
      if (visibility != 'all' && item['visibility'] != visibility) return false;
      if (categories != null && categories.isNotEmpty) {
        if (!categories.contains(item['category'])) return false;
      }
      return true;
    }).toList();

    final totalCount = filtered.length;
    final totalPages = (totalCount / limit).ceil();
    final startIndex = (page - 1) * limit;
    final data = filtered.skip(startIndex).take(limit).map((k) {
       return {
         ..._summaryFromKahoot(k),
         'status': k['status'],
         'visibility': k['visibility'],
         'createdAt': k['createdAt'],
         'gameId': k['gameId'],
         'gameType': k['gameType'],
       };
    }).toList();

    return {
      'data': data,
      'pagination': {
        'page': page,
        'limit': limit,
        'totalCount': totalCount,
        'totalPages': totalPages,
      }
    };
  }

  // H7.1 My Creations
  router.get('/library/my-creations', (Request req) {
    final myKahoots = _kahoots.where((k) => k['authorId'] == 'author-demo-001').toList();
    return _json(_paginateAndFilter(myKahoots, req));
  });

  // H7.2 Favorites
  router.get('/library/favorites', (Request req) {
    final favs = _kahoots.where((k) => _userFavorites.contains(k['id'])).toList();
    return _json(_paginateAndFilter(favs, req));
  });

  // H7.3 Mark as Favorite
  router.post('/library/favorites/<id>', (Request req, String id) {
    if (!_kahoots.any((k) => k['id'] == id)) return _notFound();
    if (_userFavorites.contains(id)) {
      return Response(409, body: 'Already a favorite');
    }
    _userFavorites.add(id);
    return Response(201);
  });

  // H7.4 Unmark as Favorite
  router.delete('/library/favorites/<id>', (Request req, String id) {
     if (!_kahoots.any((k) => k['id'] == id)) return _notFound();
     _userFavorites.remove(id);
     return Response(204);
  });

  // H7.5 In Progress
  router.get('/library/in-progress', (Request req) {
    return _json(_paginateAndFilter(_userInProgress, req));
  });

  // H7.6 Completed
  router.get('/library/completed', (Request req) {
    return _json(_paginateAndFilter(_userCompleted, req));
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
