import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class DuplicateSlideUseCase {
  DuplicateSlideUseCase(this.repository);

  final SlidesRepository repository;

  Future<Slide> call(String kahootId, String slideId) {
    return repository.duplicateSlide(kahootId, slideId);
  }
}
