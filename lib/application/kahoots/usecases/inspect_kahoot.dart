import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

class InspectKahootUseCase {
  InspectKahootUseCase(this.repository);

  final KahootsRepository repository;

  Future<Kahoot> call(String kahootId) {
    return repository.inspectKahoot(kahootId);
  }
}
