import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class UpdateSlideUseCase {
  UpdateSlideUseCase(this.repository);

  final SlidesRepository repository;

  Future<Slide> call(String kahootId, Slide slide) {
    return repository.updateSlide(kahootId, slide);
  }
}
