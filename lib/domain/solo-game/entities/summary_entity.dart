class SummaryEntity {
  final String attemptId;
  final int finalScore;
  final int totalCorrect;
  final int totalQuestions;
  final int accuracyPercentage;

  SummaryEntity({
    required this.attemptId,
    required this.finalScore,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.accuracyPercentage,
  });
}
