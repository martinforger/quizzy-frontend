import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

class GetKahootUseCase {
  GetKahootUseCase(this.repository);

  final KahootsRepository repository;

  Future<Kahoot> call(String kahootId) {
    return repository.getKahoot(kahootId);
  }
}
