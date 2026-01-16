class KahootResultSummary {
  KahootResultSummary({
    required this.kahootId,
    required this.gameId,
    required this.gameType,
    required this.title,
    required this.completionDate,
    required this.finalScore,
    required this.rankingPosition,
  });

  final String kahootId;
  final String gameId;
  final String gameType;
  final String title;
  final DateTime completionDate;
  final int finalScore;
  final int? rankingPosition;
}
