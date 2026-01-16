/// Represents an entry in the group leaderboard.
class LeaderboardEntry {
  final String id;
  final String name;
  final int completedQuizzes;
  final int totalPoints;
  final int position;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.completedQuizzes,
    required this.totalPoints,
    required this.position,
    this.avatarUrl,
  });
}
