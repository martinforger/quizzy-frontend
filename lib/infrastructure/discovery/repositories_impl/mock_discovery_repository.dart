import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
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
  Future<List<QuizSummary>> getFeaturedQuizzes() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return [
      QuizSummary(
        id: 'q1',
        title: 'Artificial Intelligence in Space',
        author: 'by MuseumOfScience',
        tag: 'Science',
      ),
      QuizSummary(
        id: 'q2',
        title: 'Ancient World Wonders',
        author: 'by HistoryBuffs',
        tag: 'History',
      ),
      QuizSummary(
        id: 'q3',
        title: 'Blockbuster Hits of the 90s',
        author: 'by CinemaClub',
        tag: 'Movies',
      ),
    ];
  }
}
