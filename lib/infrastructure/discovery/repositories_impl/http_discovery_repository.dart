import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/paginated_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/pagination.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';
import 'package:quizzy/domain/discovery/repositories/discovery_repository.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

/// Implementacion HTTP del repositorio de descubrimiento usando BackendSettings.
class HttpDiscoveryRepository implements DiscoveryRepository {
  HttpDiscoveryRepository({required this.client});

  final http.Client client;

  @override
  Future<List<Category>> getCategories() async {
    final uri = _resolve('explore/categories');
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Error al obtener categorias: ${response.statusCode}');
    }
    final dynamic decoded = json.decode(response.body);
    // El API nueva devuelve un array simple o envuelto; soportamos ambos.
    final List<dynamic> jsonList = decoded is Map<String, dynamic>
        ? (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        : (decoded as List<dynamic>);
    return jsonList
        .map((e) => _mapCategory(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<QuizSummary>> getFeaturedQuizzes({int limit = 10}) async {
    final uri = _resolve(
      'explore/featured',
      queryParameters: {'limit': '$limit'},
    );
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener quizzes destacados: ${response.statusCode}',
      );
    }
    final dynamic decoded = json.decode(response.body);
    final List<dynamic> jsonList = decoded is Map<String, dynamic>
        ? (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        : (decoded as List<dynamic>);
    return jsonList
        .map((e) => _mapQuizSummary(e as Map<String, dynamic>))
        .toList();
  }

  Category _mapCategory(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as String?) ?? (json['name'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? 'category',
      gradientStart: json['gradientStart'] as String? ?? '#6C63FF',
      gradientEnd: json['gradientEnd'] as String? ?? '#2B2E4A',
    );
  }

  QuizSummary _mapQuizSummary(Map<String, dynamic> json) {
    return QuizSummary(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled quiz',
      author: _extractAuthor(json['author']),
      tag:
          (json['category'] as String?) ??
          _extractFirstTheme(json['themes']) ??
          'General',
      thumbnailUrl:
          _resolveMedia(json['coverImageId'] as String?) ??
          (json['kahootImage'] as String?) ??
          (json['thumbnailUrl'] as String? ?? ''),
      description: json['description'] as String?,
      playCount: (json['playCount'] as num?)?.toInt(),
    );
  }

  @override
  Future<PaginatedQuizzes> searchQuizzes({
    String? query,
    List<String> themes = const [],
    int page = 1,
    int limit = 20,
    String? orderBy,
    String? order,
  }) async {
    final queryParameters = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (query != null && query.isNotEmpty) 'q': query,
      if (themes.isNotEmpty) 'categories': themes.join(','),
      if (orderBy != null && orderBy.isNotEmpty) 'orderBy': orderBy,
      if (order != null && order.isNotEmpty) 'order': order,
    };

    final uri = _resolve('explore', queryParameters: queryParameters);
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Error al buscar quizzes: ${response.statusCode}');
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> itemsJson =
        (data['data'] as List<dynamic>? ?? <dynamic>[]);
    final paginationJson =
        data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final quizzes = itemsJson
        .map((e) => _mapQuizSummary(e as Map<String, dynamic>))
        .toList();
    final pagination = _mapPagination(
      paginationJson,
      fallbackCount: quizzes.length,
    );
    return PaginatedQuizzes(items: quizzes, pagination: pagination);
  }

  @override
  Future<List<QuizTheme>> getThemes() async {
    // La API de explore expone categorías; las usamos como temas de filtro.
    final uri = _resolve('explore/categories');
    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener temas: ${response.statusCode}');
    }
    final dynamic decoded = json.decode(response.body);
    final List<dynamic> jsonList = decoded is Map<String, dynamic>
        ? (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        : (decoded as List<dynamic>);
    return jsonList
        .map((e) => _mapQuizTheme(e as Map<String, dynamic>))
        .toList();
  }

  Pagination _mapPagination(
    Map<String, dynamic> json, {
    required int fallbackCount,
  }) {
    return Pagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? fallbackCount,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? fallbackCount,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  QuizTheme _mapQuizTheme(Map<String, dynamic> json) {
    return QuizTheme(
      id: (json['id'] as String?) ?? (json['name'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      kahootCount: (json['kahootCount'] as num?)?.toInt() ?? 0,
    );
  }

  String _extractAuthor(dynamic authorJson) {
    if (authorJson is Map<String, dynamic>) {
      return authorJson['name'] as String? ?? 'Unknown';
    }
    if (authorJson is String && authorJson.isNotEmpty) {
      return authorJson;
    }
    return 'Unknown';
  }

  String? _extractFirstTheme(dynamic themesJson) {
    if (themesJson is List && themesJson.isNotEmpty) {
      final first = themesJson.first;
      if (first is String) return first;
      if (first is Map<String, dynamic>) return first['name'] as String?;
    }
    return null;
  }

  String? _resolveMedia(String? mediaIdOrUrl) {
    if (mediaIdOrUrl == null || mediaIdOrUrl.isEmpty) return null;
    if (mediaIdOrUrl.startsWith('http')) return mediaIdOrUrl;
    // Endpoint de media no disponible aún para ids; evitar construir URLs inválidas.
    return null;
  }

  Uri _resolve(String path, {Map<String, String>? queryParameters}) {
    final base = BackendSettings.baseUrl;
    final separator = base.endsWith('/') ? '' : '/';
    return Uri.parse(
      '$base$separator$path',
    ).replace(queryParameters: queryParameters);
  }
}
