import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzy/domain/library/entities/library_item.dart';
import 'package:quizzy/domain/library/repositories/i_library_repository.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

class HttpLibraryRepository implements ILibraryRepository {
  HttpLibraryRepository({required this.client});

  final http.Client client;

  Uri _resolve(String path, [Map<String, dynamic>? queryParameters]) {
    final baseUrl = BackendSettings.baseUrl;
    final effectiveBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final effectivePath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse('$effectiveBaseUrl$effectivePath');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final newQueryParameters = Map<String, dynamic>.from(uri.queryParameters);
      newQueryParameters.addAll(queryParameters);

      return uri.replace(queryParameters: newQueryParameters);
    }
    return uri;
  }

  Map<String, dynamic> _paramsToMap(LibraryQueryParams params) {
    final map = <String, dynamic>{
      'page': params.page.toString(),
      'limit': params.limit.toString(),
      'status': params.status,
      'visibility': params.visibility,
      'orderBy': params.orderBy,
      'order': params.order,
    };
    if (params.q != null && params.q!.isNotEmpty) {
      map['q'] = params.q;
    }
    if (params.categories.isNotEmpty) {
      map['categories'] = params.categories;
    }
    return map;
  }

  void _ensureSuccess(
    http.Response response,
    String message, {
    List<int> expected = const [200],
  }) {
    if (!expected.contains(response.statusCode)) {
      throw Exception('$message: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<LibraryResponse> getMyCreations(LibraryQueryParams params) async {
    final uri = _resolve('/library/my-creations', _paramsToMap(params));
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error fetching creations');
    return _parseResponse(response.body);
  }

  @override
  Future<LibraryResponse> getFavorites(LibraryQueryParams params) async {
    final uri = _resolve('/library/favorites', _paramsToMap(params));
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error fetching favorites');
    return _parseResponse(response.body);
  }

  @override
  Future<void> markAsFavorite(String kahootId) async {
    final uri = _resolve('/library/favorites/$kahootId');
    final response = await client.post(uri);
    _ensureSuccess(response, 'Error marking as favorite', expected: [201]);
  }

  @override
  Future<void> unmarkAsFavorite(String kahootId) async {
    final uri = _resolve('/library/favorites/$kahootId');
    final response = await client.delete(uri);
    _ensureSuccess(response, 'Error unmarking as favorite', expected: [204]);
  }

  @override
  Future<LibraryResponse> getInProgress(LibraryQueryParams params) async {
    final uri = _resolve('/library/in-progress', _paramsToMap(params));
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error fetching in-progress');
    return _parseResponse(response.body);
  }

  @override
  Future<LibraryResponse> getCompleted(LibraryQueryParams params) async {
    final uri = _resolve('/library/completed', _paramsToMap(params));
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error fetching completed');
    return _parseResponse(response.body);
  }

  LibraryResponse _parseResponse(String body) {
    final jsonMap = json.decode(body) as Map<String, dynamic>;
    final dataList = (jsonMap['data'] as List).map((e) => _mapItem(e)).toList();
    final pagination = _mapPagination(jsonMap['pagination']);
    return LibraryResponse(data: dataList, pagination: pagination);
  }

  LibraryItem _mapItem(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coverImageId: json['coverImageId'],
      visibility: json['visibility'],
      themeId: json['themeId'],
      author: json['author'] != null ? _mapAuthor(json['author']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      playCount: json['playCount'],
      category: json['category'],
      status:
          json['Status'] ??
          json['status'], // Note: prompt says "Status" capitalized in some examples! handling both
      gameId: json['gameId'],
      gameType: json['gameType'],
    );
  }

  LibraryAuthor _mapAuthor(Map<String, dynamic> json) {
    return LibraryAuthor(id: json['id'], name: json['name']);
  }

  LibraryPagination _mapPagination(Map<String, dynamic> json) {
    return LibraryPagination(
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
    );
  }
}
