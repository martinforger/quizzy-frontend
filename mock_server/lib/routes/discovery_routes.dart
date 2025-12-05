import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rutas de descubrimiento: categorías, temas, listado/paginación y destacados.
class DiscoveryRoutes {
  DiscoveryRoutes(this._dataDir);

  final Directory _dataDir;

  Router get router {
    final router = Router();
    // Rutas legacy bajo /discovery
    router.get('/categories', _categories);
    router.get('/featured', _featured);
    router.get('/quizzes', _legacyQuizzes);
    return router;
  }

  // Handlers públicos para montarlos en la raíz
  Response categories(Request request) => _categories(request);
  Response themes(Request request) => _themes(request);
  Response kahoots(Request request) => _kahoots(request);
  Response featured(Request request) => _featured(request);

  Response _categories(Request request) {
    final body = _readJson('categories.json');
    return Response.ok(body, headers: {'content-type': 'application/json'});
  }

  Response _themes(Request request) {
    final body = _readJson('themes.json');
    return Response.ok(body, headers: {'content-type': 'application/json'});
  }

  Response _featured(Request request) {
    final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
    final quizzes = _readQuizzes();
    quizzes.sort((a, b) {
      final playA = (a['playCount'] as num? ?? 0).toInt();
      final playB = (b['playCount'] as num? ?? 0).toInt();
      return playB.compareTo(playA);
    });
    final sliced = quizzes.take(limit).toList();
    return Response.ok(jsonEncode(sliced), headers: {'content-type': 'application/json'});
  }

  // Legacy endpoint que devuelve la lista completa sin paginar.
  Response _legacyQuizzes(Request request) {
    final body = _readJson('quizzes.json');
    return Response.ok(body, headers: {'content-type': 'application/json'});
  }

  Response _kahoots(Request request) {
    final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
    final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
    final query = request.url.queryParameters['q']?.toLowerCase() ?? '';
    final themesParam = request.url.queryParameters['themes'] ?? '';
    final orderBy = request.url.queryParameters['orderBy'] ?? 'createdAt';
    final order = (request.url.queryParameters['order'] ?? 'desc').toLowerCase();

    final themesFilter = themesParam.isEmpty
        ? <String>[]
        : themesParam.split(',').map((t) => t.trim().toLowerCase()).where((t) => t.isNotEmpty).toList();

    var quizzes = _readQuizzes();

    if (query.isNotEmpty) {
      quizzes = quizzes.where((quiz) {
        final title = (quiz['title'] as String? ?? '').toLowerCase();
        final description = (quiz['description'] as String? ?? '').toLowerCase();
        final author = ((quiz['author']?['name']) as String? ?? '').toLowerCase();
        return title.contains(query) || description.contains(query) || author.contains(query);
      }).toList();
    }

    if (themesFilter.isNotEmpty) {
      quizzes = quizzes.where((quiz) {
        final themes = (quiz['themes'] as List<dynamic>? ?? [])
            .map((t) => (t as String).toLowerCase())
            .toList();
        return themes.any((t) => themesFilter.contains(t));
      }).toList();
    }

    quizzes.sort((a, b) => _compare(a, b, orderBy, order));

    final totalCount = quizzes.length;
    final start = (page - 1) * limit;
    final end = (start + limit) > totalCount ? totalCount : (start + limit);
    final paginated = start < totalCount ? quizzes.sublist(start, end) : <Map<String, dynamic>>[];
    final totalPages = (totalCount / limit).ceil();

    final body = jsonEncode({
      'data': paginated,
      'pagination': {
        'page': page,
        'limit': limit,
        'totalCount': totalCount,
        'totalPages': totalPages,
      },
    });

    return Response.ok(body, headers: {'content-type': 'application/json'});
  }

  int _compare(Map<String, dynamic> a, Map<String, dynamic> b, String orderBy, String order) {
    int factor = order == 'asc' ? 1 : -1;
    switch (orderBy) {
      case 'title':
        return factor * (a['title'] as String).compareTo(b['title'] as String);
      case 'playCount':
      case 'likesCount': // fallback
        final av = (a['playCount'] as num? ?? 0).toInt();
        final bv = (b['playCount'] as num? ?? 0).toInt();
        return factor * av.compareTo(bv);
      case 'createdAt':
      default:
        DateTime parse(dynamic v) => DateTime.tryParse(v as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return factor * parse(a['createdAt']).compareTo(parse(b['createdAt']));
    }
  }

  List<Map<String, dynamic>> _readQuizzes() {
    final file = File('${_dataDir.path}/quizzes.json');
    final content = file.readAsStringSync();
    final decoded = json.decode(content) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  String _readJson(String fileName) {
    final file = File('${_dataDir.path}/$fileName');
    return file.readAsStringSync();
  }
}
