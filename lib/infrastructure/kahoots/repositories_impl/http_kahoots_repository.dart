import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/kahoots/entities/game_state.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

class HttpKahootsRepository implements KahootsRepository {
  HttpKahootsRepository({required this.client});

  final http.Client client;

  @override
  Future<Kahoot> createKahoot(Kahoot kahoot) async {
    final uri = _resolve('kahoots');
    final response = await client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode(_toJson(kahoot)),
        )
        .timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al crear kahoot', expected: [201]);
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<Kahoot> updateKahoot(Kahoot kahoot) async {
    if (kahoot.id == null)
      throw Exception('kahoot.id requerido para actualizar');
    final uri = _resolve('kahoots/${kahoot.id}');
    final response = await client
        .put(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode(_toJson(kahoot)),
        )
        .timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al actualizar kahoot');
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<Kahoot> getKahoot(String kahootId) async {
    final uri = _resolve('kahoots/$kahootId');
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al obtener kahoot');
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<Kahoot> inspectKahoot(String kahootId) async {
    final uri = _resolve('kahoots/inspect/$kahootId');
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al inspeccionar kahoot');
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return _mapKahoot(data);
  }

  @override
  Future<void> deleteKahoot(String kahootId) async {
    final uri = _resolve('kahoots/$kahootId');
    final response = await client
        .delete(uri)
        .timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al borrar kahoot', expected: [200, 204]);
  }

  Kahoot _mapKahoot(Map<String, dynamic> json) {
    return Kahoot(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      coverImageId: json['coverImageId'] as String?,
      visibility: (json['visibility'] as String?)?.toLowerCase(),
      themeId: json['themeId'] as String?,
      authorId: json['author'] is Map
          ? json['author']['id'] as String?
          : json['authorId'] as String?,
      authorName: json['author'] is Map
          ? json['author']['name'] as String?
          : null,
      category: json['category'] as String?,
      status: (json['status'] as String?)?.toLowerCase() == 'publish'
          ? 'published'
          : 'draft',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      playCount: (json['playCount'] as num?)?.toInt(),
      isInProgress: json['isInProgress'] as bool?,
      isCompleted: json['isCompleted'] as bool?,
      isFavorite: json['isFavorite'] as bool?,
      gameState: json['gameState'] != null
          ? _mapGameState(json['gameState'] as Map<String, dynamic>)
          : null,
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
      type: _mapTypeFromApi(json['type'] as String?),
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
    final map = <String, dynamic>{
      'title': kahoot.title,
      'description': kahoot.description,
      'coverImageId': kahoot.coverImageId,
      'visibility': kahoot.visibility == 'public' ? 'Public' : 'Private',
      'themeId': kahoot.themeId,
      'category': kahoot.category,
      'status': kahoot.status == 'published' ? 'Publish' : 'Draft',
      'questions': kahoot.questions.map((q) {
        final qMap = <String, dynamic>{
          'text': q.text,
          'mediaId': q.mediaId,
          'type': _mapTypeToApi(q.type, q.answers),
          'timeLimit': q.timeLimit,
          'points': q.points ?? 1000,
          'answers': q.answers
              .map(
                (a) => {
                  if (a.id != null) 'id': a.id,
                  'text': a.text,
                  'mediaId': a.mediaId,
                  'isCorrect': a.isCorrect,
                },
              )
              .toList(),
        };
        if (q.id != null) qMap['id'] = q.id;
        return qMap;
      }).toList(),
    };
    return map;
  }

  GameState _mapGameState(Map<String, dynamic> json) {
    return GameState(
      attemptId: json['attemptId'] as String?,
      currentScore: (json['currentScore'] as num?)?.toInt(),
      currentSlide: (json['currentSlide'] as num?)?.toInt(),
      totalSlides: (json['totalSlides'] as num?)?.toInt(),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.tryParse(json['lastPlayedAt'] as String)
          : null,
    );
  }

  String? _mapTypeToApi(String? type, List<KahootAnswer> answers) {
    if (type == 'quiz') {
      final correctCount = answers.where((a) => a.isCorrect).length;
      return correctCount > 1 ? 'multiple' : 'single';
    }
    if (type == 'trueFalse') return 'true_false';
    return type;
  }

  String? _mapTypeFromApi(String? type) {
    if (type == 'single' || type == 'multiple') return 'quiz';
    if (type == 'true_false') return 'trueFalse';
    return type;
  }

  Uri _resolve(String path) {
    final base = BackendSettings.baseUrl;
    final separator = base.endsWith('/') ? '' : '/';
    return Uri.parse('$base$separator$path');
  }

  void _ensureSuccess(
    http.Response response,
    String message, {
    List<int> expected = const [200],
  }) {
    if (!expected.contains(response.statusCode)) {
      throw Exception('$message: ${response.statusCode} ${response.body}');
    }
  }
}
