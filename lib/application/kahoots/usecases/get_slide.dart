import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class GetSlideUseCase {
  GetSlideUseCase(this.repository);

  final SlidesRepository repository;

  Future<Slide> call(String kahootId, String slideId) {
    return repository.getSlide(kahootId, slideId);
  }
}
