import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

class CreateKahootUseCase {
  CreateKahootUseCase(this.repository);

  final KahootsRepository repository;

  Future<Kahoot> call(Kahoot kahoot) {
    return repository.createKahoot(kahoot);
  }
}
