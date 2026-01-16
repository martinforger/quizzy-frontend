import 'package:quizzy/domain/library/repositories/i_library_repository.dart';

class UnmarkAsFavoriteUseCase {
  UnmarkAsFavoriteUseCase(this.repository);

  final ILibraryRepository repository;

  Future<void> call(String kahootId) {
    return repository.unmarkAsFavorite(kahootId);
  }
}
