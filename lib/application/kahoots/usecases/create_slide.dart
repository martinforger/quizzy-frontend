import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class CreateSlideUseCase {
  CreateSlideUseCase(this.repository);

  final SlidesRepository repository;

  Future<Slide> call(String kahootId, Slide slide) {
    return repository.createSlide(kahootId, slide);
  }
}
