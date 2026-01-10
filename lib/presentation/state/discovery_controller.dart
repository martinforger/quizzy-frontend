import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/paginated_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';

import 'package:quizzy/application/library/usecases/mark_as_favorite.dart';
import 'package:quizzy/application/library/usecases/unmark_as_favorite.dart';

class DiscoveryController {
  DiscoveryController({
    required this.getCategoriesUseCase,
    required this.getFeaturedQuizzesUseCase,
    required this.searchQuizzesUseCase,
    required this.getThemesUseCase,
    required this.markAsFavoriteUseCase,
    required this.unmarkAsFavoriteUseCase,
  });

  final GetCategoriesUseCase getCategoriesUseCase;
  final GetFeaturedQuizzesUseCase getFeaturedQuizzesUseCase;
  final SearchQuizzesUseCase searchQuizzesUseCase;
  final GetThemesUseCase getThemesUseCase;
  final MarkAsFavoriteUseCase markAsFavoriteUseCase;
  final UnmarkAsFavoriteUseCase unmarkAsFavoriteUseCase;

  // Obtiene categorias desde el caso de uso.
  Future<List<Category>> fetchCategories() {
    return getCategoriesUseCase();
  }

  // Obtiene quizzes destacados desde el caso de uso.
  Future<List<QuizSummary>> fetchFeaturedQuizzes({int limit = 10}) {
    return getFeaturedQuizzesUseCase(limit: limit);
  }

  // Realiza una búsqueda y devuelve solo los items para simplificar la UI.
  Future<List<QuizSummary>> searchQuizSummaries({
    String? query,
    List<String> themes = const [],
    int page = 1,
    int limit = 20,
    String? orderBy,
    String? order,
  }) async {
    final result = await searchQuizzesUseCase(
      query: query,
      themes: themes,
      page: page,
      limit: limit,
      orderBy: orderBy,
      order: order,
    );
    return result.items;
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

  Future<void> toggleFavorite(String quizId, bool isFavorite) async {
    if (isFavorite) {
      await unmarkAsFavoriteUseCase(quizId);
    } else {
      await markAsFavoriteUseCase(quizId);
    }
  }
}
