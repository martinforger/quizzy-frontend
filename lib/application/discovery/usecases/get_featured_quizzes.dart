import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/repositories/discovery_repository.dart';

class GetFeaturedQuizzesUseCase {
  GetFeaturedQuizzesUseCase(this.repository);

  final DiscoveryRepository repository;

  // Ejecuta el flujo para obtener los quizzes destacados.
  Future<List<QuizSummary>> call() {
    return repository.getFeaturedQuizzes();
  }
}
