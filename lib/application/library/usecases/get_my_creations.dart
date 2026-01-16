import 'package:quizzy/domain/library/entities/library_item.dart';
import 'package:quizzy/domain/library/repositories/i_library_repository.dart';

class GetMyCreationsUseCase {
  GetMyCreationsUseCase(this.repository);

  final ILibraryRepository repository;

  Future<LibraryResponse> call(LibraryQueryParams params) {
    return repository.getMyCreations(params);
  }
}
