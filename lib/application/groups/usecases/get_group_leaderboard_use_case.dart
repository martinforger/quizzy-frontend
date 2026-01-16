import '../../../domain/groups/entities/leaderboard_entry.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to get the group leaderboard.
class GetGroupLeaderboardUseCase {
  final GroupRepository _repository;

  GetGroupLeaderboardUseCase(this._repository);

  Future<List<LeaderboardEntry>> call({
    required String groupId,
    required String accessToken,
  }) {
    return _repository.getGroupLeaderboard(
      groupId: groupId,
      accessToken: accessToken,
    );
  }
}
