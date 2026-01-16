import '../../../domain/groups/entities/leaderboard_entry.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to get the leaderboard for a specific quiz.
class GetQuizLeaderboardUseCase {
  final GroupRepository _repository;

  GetQuizLeaderboardUseCase(this._repository);

  Future<List<LeaderboardEntry>> call({
    required String groupId,
    required String quizId,
    required String accessToken,
  }) {
    return _repository.getQuizLeaderboard(
      groupId: groupId,
      quizId: quizId,
      accessToken: accessToken,
    );
  }
}
