import 'package:quizzy/domain/discovery/entities/paginated_quizzes.dart';
import 'package:quizzy/domain/discovery/repositories/discovery_repository.dart';

class SearchQuizzesUseCase {
  SearchQuizzesUseCase(this.repository);

  final DiscoveryRepository repository;

  Future<PaginatedQuizzes> call({
    String? query,
    List<String> themes = const [],
    int page = 1,
    int limit = 20,
    String? orderBy,
    String? order,
  }) {
    return repository.searchQuizzes(
      query: query,
      themes: themes,
      page: page,
      limit: limit,
      orderBy: orderBy,
      order: order,
    );
  }
}
