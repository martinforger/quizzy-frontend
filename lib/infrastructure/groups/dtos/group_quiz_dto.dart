import '../../../domain/groups/entities/group_quiz.dart';

/// DTO for GroupQuiz API responses.
class GroupQuizDto {
  final String assignmentId;
  final String quizId;
  final String title;
  final DateTime availableUntil;
  final String status;
  final Map<String, dynamic>? userResult;
  final List<Map<String, dynamic>> leaderboard;

  GroupQuizDto({
    required this.assignmentId,
    required this.quizId,
    required this.title,
    required this.availableUntil,
    required this.status,
    this.userResult,
    this.leaderboard = const [],
  });

  factory GroupQuizDto.fromJson(Map<String, dynamic> json) {
    return GroupQuizDto(
      assignmentId:
          json['assignmentId'] as String? ?? json['id'] as String? ?? '',
      quizId: json['quizId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Quiz',
      availableUntil: json['availableUntil'] != null
          ? DateTime.parse(json['availableUntil'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      status: json['status'] as String? ?? 'PENDING',
      userResult: json['userResult'] as Map<String, dynamic>?,
      leaderboard:
          (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  GroupQuiz toDomain() {
    QuizUserResult? result;
    if (userResult != null) {
      result = QuizUserResult(
        score: (userResult!['score'] as num?)?.toInt() ?? 0,
        attemptId: userResult!['attemptId'] as String? ?? '',
        completedAt: userResult!['completedAt'] != null
            ? DateTime.parse(userResult!['completedAt'] as String)
            : DateTime.now(),
      );
    }

    final leaderboardEntries = leaderboard
        .map(
          (e) => QuizLeaderboardEntry(
            name: e['name'] as String? ?? 'Unknown',
            score: (e['score'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();

    return GroupQuiz(
      assignmentId: assignmentId,
      quizId: quizId,
      title: title,
      availableUntil: availableUntil,
      status: QuizStatusExtension.fromString(status),
      userResult: result,
      leaderboard: leaderboardEntries,
    );
  }
}
