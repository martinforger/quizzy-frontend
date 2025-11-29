import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';

class DiscoveryController {
  DiscoveryController({
    required this.getCategoriesUseCase,
    required this.getFeaturedQuizzesUseCase,
  });

  final GetCategoriesUseCase getCategoriesUseCase;
  final GetFeaturedQuizzesUseCase getFeaturedQuizzesUseCase;

  // Obtiene categor?as desde el caso de uso.
  Future<List<Category>> fetchCategories() {
    return getCategoriesUseCase();
  }

  // Obtiene quizzes destacados desde el caso de uso.
  Future<List<QuizSummary>> fetchFeaturedQuizzes() {
    return getFeaturedQuizzesUseCase();
  }
}
