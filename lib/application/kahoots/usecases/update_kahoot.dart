import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

class UpdateKahootUseCase {
  UpdateKahootUseCase(this.repository);

  final KahootsRepository repository;

  Future<Kahoot> call(Kahoot kahoot) {
    return repository.updateKahoot(kahoot);
  }
}
