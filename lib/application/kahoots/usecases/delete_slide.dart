import 'package:quizzy/domain/kahoots/repositories/slides_repository.dart';

class DeleteSlideUseCase {
  DeleteSlideUseCase(this.repository);

  final SlidesRepository repository;

  Future<void> call(String kahootId, String slideId) {
    return repository.deleteSlide(kahootId, slideId);
  }
}
