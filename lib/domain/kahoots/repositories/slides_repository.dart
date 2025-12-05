import 'package:quizzy/domain/kahoots/entities/slide.dart';

abstract class SlidesRepository {
  Future<List<Slide>> listSlides(String kahootId);
  Future<Slide> getSlide(String kahootId, String slideId);
  Future<Slide> createSlide(String kahootId, Slide slide);
  Future<Slide> updateSlide(String kahootId, Slide slide);
  Future<Slide> duplicateSlide(String kahootId, String slideId);
  Future<void> deleteSlide(String kahootId, String slideId);
}
