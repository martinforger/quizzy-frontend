import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/media/entities/media_asset.dart';
import 'package:quizzy/domain/media/repositories/media_repository.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

class HttpMediaRepository implements MediaRepository {
  HttpMediaRepository({required this.client});

  final http.Client client;

  @override
  Future<MediaAsset> uploadMedia({
    required List<int> bytes,
    required String filename,
    String? category,
  }) async {
    final uri = _resolve('media/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    if (category != null && category.isNotEmpty) {
      request.fields['category'] = category;
    }
    final response = await client.send(request);
    final body = await response.stream.bytesToString();
    if (response.statusCode != 201) {
      throw Exception('Error al subir media: ${response.statusCode} $body');
    }
    final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
    return _mapAsset(data);
  }

  @override
  Future<List<MediaAsset>> listThemeMedia() async {
    final uri = _resolve('media/themes');
    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener media themes: ${response.statusCode}');
    }
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList.map((e) => _mapAsset(e as Map<String, dynamic>)).toList();
  }

  MediaAsset _mapAsset(Map<String, dynamic> json) {
    return MediaAsset(
      assetId: json['assetId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      name: json['name'] as String?,
      category: json['category'] as String?,
      format: json['format'] as String?,
      size: (json['size'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
    );
  }

  Uri _resolve(String path) {
    final base = BackendSettings.baseUrl;
    final separator = base.endsWith('/') ? '' : '/';
    return Uri.parse('$base$separator$path');
  }
}
