import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

class HttpKahootsRepository implements KahootsRepository {
  HttpKahootsRepository({
    required this.client,
    required String baseUrl,
  }) : _baseUri = Uri.parse(baseUrl);

  final http.Client client;
  final Uri _baseUri;

  @override
  Future<Kahoot> createKahoot(Kahoot kahoot) async {
    final uri = _resolve('kahoots');
    final response = await client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(_toJson(kahoot)),
    );
    _ensureSuccess(response, 'Error al crear kahoot', expected: [201]);
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<Kahoot> updateKahoot(Kahoot kahoot) async {
    if (kahoot.id == null) throw Exception('kahoot.id requerido para actualizar');
    final uri = _resolve('kahoots/${kahoot.id}');
    final response = await client.put(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(_toJson(kahoot)),
    );
    _ensureSuccess(response, 'Error al actualizar kahoot');
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<Kahoot> getKahoot(String kahootId) async {
    final uri = _resolve('kahoots/$kahootId');
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error al obtener kahoot');
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<void> deleteKahoot(String kahootId) async {
    final uri = _resolve('kahoots/$kahootId');
    final response = await client.delete(uri);
    _ensureSuccess(response, 'Error al borrar kahoot', expected: [200, 204]);
  }

  Kahoot _mapKahoot(Map<String, dynamic> json) {
    return Kahoot(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      coverImageId: json['coverImageId'] as String?,
      visibility: json['visibility'] as String?,
      themeId: json['themeId'] as String?,
      authorId: json['authorId'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      playCount: (json['playCount'] as num?)?.toInt(),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => _mapQuestion(q as Map<String, dynamic>))
          .toList(),
    );
  }

  KahootQuestion _mapQuestion(Map<String, dynamic> json) {
    return KahootQuestion(
      id: json['id'] as String?,
      text: json['text'] as String?,
      mediaId: json['mediaId'] as String?,
      type: json['type'] as String?,
      timeLimit: (json['timeLimit'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((a) => _mapAnswer(a as Map<String, dynamic>))
          .toList(),
    );
  }

  KahootAnswer _mapAnswer(Map<String, dynamic> json) {
    return KahootAnswer(
      id: json['id'] as String?,
      text: json['text'] as String?,
      mediaId: json['mediaId'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _toJson(Kahoot kahoot) {
    return {
      'id': kahoot.id,
      'title': kahoot.title,
      'description': kahoot.description,
      'coverImageId': kahoot.coverImageId,
      'visibility': kahoot.visibility,
      'themeId': kahoot.themeId,
      'authorId': kahoot.authorId,
      'category': kahoot.category,
      'status': kahoot.status,
      'questions': kahoot.questions.map((q) {
        return {
          'id': q.id,
          'text': q.text,
          'mediaId': q.mediaId,
          'type': q.type,
          'timeLimit': q.timeLimit,
          'points': q.points,
          'answers': q.answers
              .map((a) => {
                    'id': a.id,
                    'text': a.text,
                    'mediaId': a.mediaId,
                    'isCorrect': a.isCorrect,
                  })
              .toList(),
        };
      }).toList(),
    };
  }

  Uri _resolve(String path) {
    final base = _baseUri.toString();
    final separator = base.endsWith('/') ? '' : '/';
    return Uri.parse('$base$separator$path');
  }

  void _ensureSuccess(http.Response response, String message, {List<int> expected = const [200]}) {
    if (!expected.contains(response.statusCode)) {
      throw Exception('$message: ${response.statusCode} ${response.body}');
    }
  }
}
