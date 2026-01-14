class SessionReport {
  SessionReport({
    required this.reportId,
    required this.sessionId,
    required this.title,
    required this.executionDate,
    required this.playerRanking,
    required this.questionAnalysis,
  });

  final String reportId;
  final String sessionId;
  final String title;
  final DateTime executionDate;
  final List<PlayerRanking> playerRanking;
  final List<QuestionAnalysis> questionAnalysis;
}

class PlayerRanking {
  PlayerRanking({
    required this.position,
    required this.username,
    required this.score,
    required this.correctAnswers,
  });

  final int position;
  final String username;
  final int score;
  final int correctAnswers;
}

class QuestionAnalysis {
  QuestionAnalysis({
    required this.questionIndex,
    required this.questionText,
    required this.correctPercentage,
  });

  final int questionIndex;
  final String questionText;
  final double correctPercentage;
}
