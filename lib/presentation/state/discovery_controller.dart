import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/paginated_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';

class DiscoveryController {
  DiscoveryController({
    required this.getCategoriesUseCase,
    required this.getFeaturedQuizzesUseCase,
    required this.searchQuizzesUseCase,
    required this.getThemesUseCase,
  });

  final GetCategoriesUseCase getCategoriesUseCase;
  final GetFeaturedQuizzesUseCase getFeaturedQuizzesUseCase;
  final SearchQuizzesUseCase searchQuizzesUseCase;
  final GetThemesUseCase getThemesUseCase;

  // Obtiene categorias desde el caso de uso.
  Future<List<Category>> fetchCategories() {
    return getCategoriesUseCase();
  }

  // Obtiene quizzes destacados desde el caso de uso.
  Future<List<QuizSummary>> fetchFeaturedQuizzes({int limit = 10}) {
    return getFeaturedQuizzesUseCase(limit: limit);
  }

  Future<PaginatedQuizzes> searchQuizzes({
    String? query,
    List<String> themes = const [],
    int page = 1,
    int limit = 20,
    String? orderBy,
    String? order,
  }) {
    return searchQuizzesUseCase(
      query: query,
      themes: themes,
      page: page,
      limit: limit,
      orderBy: orderBy,
      order: order,
    );
  }

  Future<List<QuizTheme>> fetchThemes() {
    return getThemesUseCase();
  }
}
