import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class ListSlidesUseCase {
  ListSlidesUseCase(this.repository);

  final SlidesRepository repository;

  Future<List<Slide>> call(String kahootId) {
    return repository.listSlides(kahootId);
  }
}
