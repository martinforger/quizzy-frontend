import '../../../domain/groups/entities/leaderboard_entry.dart';

/// DTO for LeaderboardEntry API responses.
class LeaderboardEntryDto {
  final String id;
  final String name;
  final int completedQuizzes;
  final int totalPoints;
  final int position;
  final String? avatarUrl;

  LeaderboardEntryDto({
    required this.id,
    required this.name,
    required this.completedQuizzes,
    required this.totalPoints,
    required this.position,
    this.avatarUrl,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json, int index) {
    return LeaderboardEntryDto(
      id: json['userId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      completedQuizzes: (json['completedQuizzes'] as num?)?.toInt() ?? 0,
      totalPoints:
          (json['totalPoints'] as num?)?.toInt() ??
          (json['score'] as num?)?.toInt() ??
          0,
      position: (json['position'] as num?)?.toInt() ?? index + 1,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  LeaderboardEntry toDomain() {
    return LeaderboardEntry(
      id: id,
      name: name,
      completedQuizzes: completedQuizzes,
      totalPoints: totalPoints,
      position: position,
      avatarUrl: avatarUrl,
    );
  }
}
