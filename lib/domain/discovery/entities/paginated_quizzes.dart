import 'package:quizzy/domain/discovery/entities/pagination.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';

class PaginatedQuizzes {
  const PaginatedQuizzes({
    required this.items,
    required this.pagination,
  });

  final List<QuizSummary> items;
  final Pagination pagination;
}
