import 'package:quizzy/domain/library/repositories/i_library_repository.dart';

class MarkAsFavoriteUseCase {
  MarkAsFavoriteUseCase(this.repository);

  final ILibraryRepository repository;

  Future<void> call(String kahootId) {
    return repository.markAsFavorite(kahootId);
  }
}
