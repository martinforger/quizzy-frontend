import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

class DeleteKahootUseCase {
  DeleteKahootUseCase(this.repository);

  final KahootsRepository repository;

  Future<void> call(String kahootId) {
    return repository.deleteKahoot(kahootId);
  }
}
