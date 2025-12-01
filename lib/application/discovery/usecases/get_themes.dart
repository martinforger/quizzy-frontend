import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';
import 'package:quizzy/domain/discovery/repositories/discovery_repository.dart';

class GetThemesUseCase {
  GetThemesUseCase(this.repository);

  final DiscoveryRepository repository;

  Future<List<QuizTheme>> call() {
    return repository.getThemes();
  }
}
