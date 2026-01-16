/// Status of a quiz assignment for the current user.
enum QuizStatus { pending, completed }

/// Extension to parse QuizStatus from string.
extension QuizStatusExtension on QuizStatus {
  String get value {
    switch (this) {
      case QuizStatus.pending:
        return 'PENDING';
      case QuizStatus.completed:
        return 'COMPLETED';
    }
  }

  static QuizStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'COMPLETED':
        return QuizStatus.completed;
      case 'PENDING':
      default:
        return QuizStatus.pending;
    }
  }
}

/// Represents a user's result on a quiz.
class QuizUserResult {
  final int score;
  final String attemptId;
  final DateTime completedAt;

  QuizUserResult({
    required this.score,
    required this.attemptId,
    required this.completedAt,
  });
}

/// Represents a leaderboard entry for a quiz.
class QuizLeaderboardEntry {
  final String name;
  final int score;

  QuizLeaderboardEntry({required this.name, required this.score});
}

/// Represents a quiz assigned to a group.
class GroupQuiz {
  final String assignmentId;
  final String quizId;
  final String title;
  final DateTime availableUntil;
  final QuizStatus status;
  final QuizUserResult? userResult;
  final List<QuizLeaderboardEntry> leaderboard;

  GroupQuiz({
    required this.assignmentId,
    required this.quizId,
    required this.title,
    required this.availableUntil,
    required this.status,
    this.userResult,
    this.leaderboard = const [],
  });

  /// Returns true if the quiz is still available to play.
  bool get isAvailable => DateTime.now().isBefore(availableUntil);

  /// Returns true if the user has completed this quiz.
  bool get isCompleted => status == QuizStatus.completed;
}
