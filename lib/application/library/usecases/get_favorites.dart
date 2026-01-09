import 'package:quizzy/domain/library/entities/library_item.dart';
import 'package:quizzy/domain/library/repositories/i_library_repository.dart';

class GetFavoritesUseCase {
  GetFavoritesUseCase(this.repository);

  final ILibraryRepository repository;

  Future<LibraryResponse> call(LibraryQueryParams params) {
    return repository.getFavorites(params);
  }
}
