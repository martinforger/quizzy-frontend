import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';

abstract class DiscoveryRepository {
  Future<List<Category>> getCategories();
  Future<List<QuizSummary>> getFeaturedQuizzes();
}
