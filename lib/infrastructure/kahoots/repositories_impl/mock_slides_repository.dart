import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/entities/slide_option.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class MockSlidesRepository implements SlidesRepository {
  MockSlidesRepository({List<Slide>? seed}) : _slides = seed ?? [];

  final List<Slide> _slides;

  @override
  Future<List<Slide>> listSlides(String kahootId) async {
    return _slides.where((s) => s.kahootId == kahootId).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  @override
  Future<Slide> getSlide(String kahootId, String slideId) async {
    final slide = _slides.firstWhere(
      (s) => s.kahootId == kahootId && s.id == slideId,
      orElse: () => throw Exception('Slide not found'),
    );
    return slide;
  }

  @override
  Future<Slide> createSlide(String kahootId, Slide slide) async {
    final nextPosition = (_slides.where((s) => s.kahootId == kahootId).map((s) => s.position).fold<int>(0, (p, e) => e > p ? e : p)) + 1;
    final newSlide = Slide(
      id: slide.id,
      kahootId: kahootId,
      position: slide.position != 0 ? slide.position : nextPosition,
      type: slide.type,
      text: slide.text,
      timeLimitSeconds: slide.timeLimitSeconds,
      points: slide.points,
      mediaUrlQuestion: slide.mediaUrlQuestion,
      options: slide.options,
      shortAnswerCorrectText: slide.shortAnswerCorrectText,
    );
    _slides.add(newSlide);
    return newSlide;
  }

  @override
  Future<Slide> updateSlide(String kahootId, Slide slide) async {
    final index = _slides.indexWhere((s) => s.kahootId == kahootId && s.id == slide.id);
    if (index == -1) throw Exception('Slide not found');
    _slides[index] = slide;
    return slide;
  }

  @override
  Future<Slide> duplicateSlide(String kahootId, String slideId) async {
    final original = _slides.firstWhere(
      (s) => s.kahootId == kahootId && s.id == slideId,
      orElse: () => throw Exception('Slide not found'),
    );
    final nextPosition = (_slides.where((s) => s.kahootId == kahootId).map((s) => s.position).fold<int>(0, (p, e) => e > p ? e : p)) + 1;
    final copy = Slide(
      id: '${slideId}_copy',
      kahootId: kahootId,
      position: nextPosition,
      type: original.type,
      text: original.text,
      timeLimitSeconds: original.timeLimitSeconds,
      points: original.points,
      mediaUrlQuestion: original.mediaUrlQuestion,
      options: List<SlideOption>.from(original.options),
      shortAnswerCorrectText: List<String>.from(original.shortAnswerCorrectText),
    );
    _slides.add(copy);
    return copy;
  }

  @override
  Future<void> deleteSlide(String kahootId, String slideId) async {
    _slides.removeWhere((s) => s.kahootId == kahootId && s.id == slideId);
  }
}
