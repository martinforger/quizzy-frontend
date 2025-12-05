import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rutas para gestión de slides/preguntas (épica 3) según API única.
class SlidesRoutes {
  SlidesRoutes(this._dataDir);

  final Directory _dataDir;

  Router get router {
    final router = Router();
    router.get('/<kahootId>/slides', _listSlides);
    router.get('/<kahootId>/slides/<slideId>', _getSlide);
    router.post('/<kahootId>/slides', _createSlide);
    router.patch('/<kahootId>/slides/<slideId>', _updateSlide);
    router.post('/<kahootId>/slides/<slideId>/duplicate', _duplicateSlide);
    router.delete('/<kahootId>/slides/<slideId>', _deleteSlide);
    return router;
  }

  Response _listSlides(Request request, String kahootId) {
    final slides = _readSlides().where((s) => s['kahootId'] == kahootId).toList();
    return Response.ok(jsonEncode(slides), headers: {'content-type': 'application/json'});
  }

  Response _getSlide(Request request, String kahootId, String slideId) {
    final slide = _readSlides().firstWhere(
          (s) => s['kahootId'] == kahootId && s['id'] == slideId,
          orElse: () => {},
        );
    if (slide.isEmpty) {
      return Response.notFound(jsonEncode({'message': 'Slide not found'}), headers: {'content-type': 'application/json'});
    }
    return Response.ok(jsonEncode(slide), headers: {'content-type': 'application/json'});
  }

  Future<Response> _createSlide(Request request, String kahootId) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final slides = _readSlides();
    final newId = 's-${kahootId}-${DateTime.now().millisecondsSinceEpoch}';
    final nextPosition = (slides.where((s) => s['kahootId'] == kahootId).map((s) => s['position'] as int? ?? 0).fold<int>(0, (p, e) => e > p ? e : p)) + 1;

    final newSlide = <String, dynamic>{
      'id': newId,
      'kahootId': kahootId,
      'position': data['position'] ?? nextPosition,
      'type': data['type'] ?? 'quiz_single',
      'text': data['text'] ?? '',
      'timeLimitSeconds': data['timeLimitSeconds'],
      'points': data['points'],
      'mediaUrlQuestion': data['mediaUrlQuestion'],
      'options': data['options'],
      'shortAnswerCorrectText': data['shortAnswerCorrectText'],
    };

    slides.add(newSlide);
    _writeSlides(slides);
    return Response(201, body: jsonEncode(newSlide), headers: {'content-type': 'application/json'});
  }

  Future<Response> _updateSlide(Request request, String kahootId, String slideId) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final slides = _readSlides();
    final index = slides.indexWhere((s) => s['kahootId'] == kahootId && s['id'] == slideId);
    if (index == -1) {
      return Response.notFound(jsonEncode({'message': 'Slide not found'}), headers: {'content-type': 'application/json'});
    }
    final existing = Map<String, dynamic>.from(slides[index]);
    existing.addAll(data);
    slides[index] = existing;
    _writeSlides(slides);
    return Response.ok(jsonEncode(existing), headers: {'content-type': 'application/json'});
  }

  Response _duplicateSlide(Request request, String kahootId, String slideId) {
    final slides = _readSlides();
    final original = slides.firstWhere(
      (s) => s['kahootId'] == kahootId && s['id'] == slideId,
      orElse: () => {},
    );
    if (original.isEmpty) {
      return Response.notFound(jsonEncode({'message': 'Slide not found'}), headers: {'content-type': 'application/json'});
    }
    final newId = 's-${kahootId}-${DateTime.now().millisecondsSinceEpoch}';
    final nextPosition = (slides.where((s) => s['kahootId'] == kahootId).map((s) => s['position'] as int? ?? 0).fold<int>(0, (p, e) => e > p ? e : p)) + 1;
    final copy = Map<String, dynamic>.from(original)
      ..['id'] = newId
      ..['position'] = nextPosition;
    slides.add(copy);
    _writeSlides(slides);
    return Response(201, body: jsonEncode(copy), headers: {'content-type': 'application/json'});
  }

  Response _deleteSlide(Request request, String kahootId, String slideId) {
    final slides = _readSlides();
    final updated = slides.where((s) => !(s['kahootId'] == kahootId && s['id'] == slideId)).toList();
    if (updated.length == slides.length) {
      return Response.notFound(jsonEncode({'message': 'Slide not found'}), headers: {'content-type': 'application/json'});
    }
    _writeSlides(updated);
    return Response(204);
  }

  List<Map<String, dynamic>> _readSlides() {
    final file = File('${_dataDir.path}/slides.json');
    if (!file.existsSync()) return [];
    final content = file.readAsStringSync();
    final decoded = jsonDecode(content) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  void _writeSlides(List<Map<String, dynamic>> slides) {
    final file = File('${_dataDir.path}/slides.json');
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(slides));
  }
}
