import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/entities/slide_option.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class HttpSlidesRepository implements SlidesRepository {
  HttpSlidesRepository({
    required this.client,
    required String baseUrl,
  }) : _baseUri = Uri.parse(baseUrl);

  final http.Client client;
  final Uri _baseUri;

  @override
  Future<List<Slide>> listSlides(String kahootId) async {
    final uri = _resolve('kahoots/$kahootId/slides');
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error al obtener slides');
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList.map((e) => _mapSlide(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Slide> getSlide(String kahootId, String slideId) async {
    final uri = _resolve('kahoots/$kahootId/slides/$slideId');
    final response = await client.get(uri);
    _ensureSuccess(response, 'Error al obtener slide');
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapSlide(data);
  }

  @override
  Future<Slide> createSlide(String kahootId, Slide slide) async {
    final uri = _resolve('kahoots/$kahootId/slides');
    final response = await client.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(_toJson(slide)),
    );
    _ensureSuccess(response, 'Error al crear slide', expected: [201]);
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapSlide(data);
  }

  @override
  Future<Slide> updateSlide(String kahootId, Slide slide) async {
    final uri = _resolve('kahoots/$kahootId/slides/${slide.id}');
    final response = await client.patch(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(_toJson(slide)),
    );
    _ensureSuccess(response, 'Error al actualizar slide');
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapSlide(data);
  }

  @override
  Future<Slide> duplicateSlide(String kahootId, String slideId) async {
    final uri = _resolve('kahoots/$kahootId/slides/$slideId/duplicate');
    final response = await client.post(uri);
    _ensureSuccess(response, 'Error al duplicar slide', expected: [201]);
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapSlide(data);
  }

  @override
  Future<void> deleteSlide(String kahootId, String slideId) async {
    final uri = _resolve('kahoots/$kahootId/slides/$slideId');
    final response = await client.delete(uri);
    _ensureSuccess(response, 'Error al eliminar slide', expected: [200, 204]);
  }

  Slide _mapSlide(Map<String, dynamic> json) {
    return Slide(
      id: json['id'] as String,
      kahootId: json['kahootId'] as String,
      position: (json['position'] as num?)?.toInt() ?? 1,
      type: _mapType(json['type'] as String? ?? 'quiz_single'),
      text: json['text'] as String? ?? '',
      timeLimitSeconds: (json['timeLimitSeconds'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      mediaUrlQuestion: json['mediaUrlQuestion'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => _mapOption(o as Map<String, dynamic>))
          .toList(),
      shortAnswerCorrectText:
          (json['shortAnswerCorrectText'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  SlideOption _mapOption(Map<String, dynamic> json) {
    return SlideOption(
      text: json['text'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      mediaUrlAnswer: json['mediaUrlAnswer'] as String?,
    );
  }

  Map<String, dynamic> _toJson(Slide slide) {
    return {
      'id': slide.id,
      'kahootId': slide.kahootId,
      'position': slide.position,
      'type': _typeToString(slide.type),
      'text': slide.text,
      'timeLimitSeconds': slide.timeLimitSeconds,
      'points': slide.points,
      'mediaUrlQuestion': slide.mediaUrlQuestion,
      'options': slide.options
          .map((o) => {
                'text': o.text,
                'isCorrect': o.isCorrect,
                'mediaUrlAnswer': o.mediaUrlAnswer,
              })
          .toList(),
      'shortAnswerCorrectText': slide.shortAnswerCorrectText,
    };
  }

  SlideType _mapType(String value) {
    switch (value) {
      case 'quiz_multiple':
        return SlideType.quizMultiple;
      case 'trueFalse':
      case 'true_false':
        return SlideType.trueFalse;
      case 'shortAnswer':
      case 'short_answer':
        return SlideType.shortAnswer;
      case 'poll':
        return SlideType.poll;
      case 'slide':
        return SlideType.slide;
      case 'quiz_single':
      default:
        return SlideType.quizSingle;
    }
  }

  String _typeToString(SlideType type) {
    switch (type) {
      case SlideType.quizMultiple:
        return 'quiz_multiple';
      case SlideType.trueFalse:
        return 'trueFalse';
      case SlideType.shortAnswer:
        return 'shortAnswer';
      case SlideType.poll:
        return 'poll';
      case SlideType.slide:
        return 'slide';
      case SlideType.quizSingle:
      default:
        return 'quiz_single';
    }
  }

  void _ensureSuccess(http.Response response, String message, {List<int> expected = const [200]}) {
    if (!expected.contains(response.statusCode)) {
      throw Exception('$message: ${response.statusCode} ${response.body}');
    }
  }

  Uri _resolve(String path) {
    final base = _baseUri.toString();
    final separator = base.endsWith('/') ? '' : '/';
    return Uri.parse('$base$separator$path');
  }
}
