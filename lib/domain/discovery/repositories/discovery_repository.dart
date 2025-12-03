import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/paginated_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';

abstract class DiscoveryRepository {
  Future<List<Category>> getCategories();
  Future<List<QuizSummary>> getFeaturedQuizzes({int limit = 10});
  Future<PaginatedQuizzes> searchQuizzes({
    String? query,
    List<String> themes = const [],
    int page = 1,
    int limit = 20,
    String? orderBy,
    String? order,
  });
  Future<List<QuizTheme>> getThemes();
}
