import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/paginated_quizzes.dart';
import 'package:quizzy/domain/discovery/entities/pagination.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';
import 'package:quizzy/domain/discovery/repositories/discovery_repository.dart';

class MockDiscoveryRepository implements DiscoveryRepository {
  @override
  Future<List<Category>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      Category(
        id: 'science',
        name: 'Science',
        icon: 'science',
        gradientStart: '#8358FF',
        gradientEnd: '#6B3FFF',
      ),
      Category(
        id: 'history',
        name: 'History',
        icon: 'history',
        gradientStart: '#F9B234',
        gradientEnd: '#F79B0C',
      ),
      Category(
        id: 'geography',
        name: 'Geography',
        icon: 'map',
        gradientStart: '#1DD8D2',
        gradientEnd: '#11BFB9',
      ),
    ];
  }

  @override
  Future<List<QuizSummary>> getFeaturedQuizzes({int limit = 10}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final all = [
      QuizSummary(
        id: 'q1',
        title: 'Artificial Intelligence in Space',
        author: 'by MuseumOfScience',
        tag: 'Science',
        thumbnailUrl: '',
        description: 'Explore AI applications beyond Earth.',
        playCount: 1200,
      ),
      QuizSummary(
        id: 'q2',
        title: 'Ancient World Wonders',
        author: 'by HistoryBuffs',
        tag: 'History',
        description: 'Discover the marvels of ancient civilizations.',
        playCount: 950,
      ),
      QuizSummary(
        id: 'q3',
        title: 'Blockbuster Hits of the 90s',
        author: 'by CinemaClub',
        tag: 'Movies',
        description: 'Relive the biggest movies from the 90s.',
        playCount: 640,
      ),
      QuizSummary(
        id: 'q4',
        title: 'Geography Challenge',
        author: 'by MapLovers',
        tag: 'Geography',
        description: 'Capitals, borders and curiosities.',
        playCount: 870,
      ),
      QuizSummary(
        id: 'q5',
        title: 'Biology Basics',
        author: 'by Bio101',
        tag: 'Science',
        description: 'Cell structure, DNA and ecosystems.',
        playCount: 720,
      ),
    ];
    return all.take(limit).toList();
  }

  @override
  Future<PaginatedQuizzes> searchQuizzes({
    String? query,
    List<String> themes = const [],
    int page = 1,
    int limit = 20,
    String? orderBy,
    String? order,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final all = await getFeaturedQuizzes(limit: 50);
    final lowerQuery = query?.toLowerCase() ?? '';
    final filteredByQuery = lowerQuery.isEmpty
        ? all
        : all.where((quiz) {
            return quiz.title.toLowerCase().contains(lowerQuery) ||
                quiz.author.toLowerCase().contains(lowerQuery) ||
                quiz.tag.toLowerCase().contains(lowerQuery);
          }).toList();
    final filteredByThemes = themes.isEmpty
        ? filteredByQuery
        : filteredByQuery.where((quiz) => themes.map((t) => t.toLowerCase()).contains(quiz.tag.toLowerCase())).toList();

    // Basic pagination simulation.
    final start = (page - 1) * limit;
    final end = (start + limit) > filteredByThemes.length ? filteredByThemes.length : (start + limit);
    final paginatedItems =
        start < filteredByThemes.length ? filteredByThemes.sublist(start, end) : <QuizSummary>[];
    final totalPages = (filteredByThemes.length / limit).ceil();

    return PaginatedQuizzes(
      items: paginatedItems,
      pagination: Pagination(
        page: page,
        limit: limit,
        totalCount: filteredByThemes.length,
        totalPages: totalPages,
      ),
    );
  }

  @override
  Future<List<QuizTheme>> getThemes() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return [
      QuizTheme(id: 'science', name: 'Science', description: 'STEM and experiments', kahootCount: 1200),
      QuizTheme(id: 'history', name: 'History', description: 'Events, people and timelines', kahootCount: 980),
      QuizTheme(id: 'geography', name: 'Geography', description: 'Maps, countries and capitals', kahootCount: 760),
      QuizTheme(id: 'movies', name: 'Movies', description: 'Cinema, actors and awards', kahootCount: 530),
    ];
  }
}
