class PersonalResult {
  PersonalResult({
    required this.kahootId,
    required this.title,
    required this.userId,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.averageTimeMs,
    required this.rankingPosition,
    required this.questionResults,
  });

  final String kahootId;
  final String title;
  final String userId;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int averageTimeMs;
  final int? rankingPosition;
  final List<QuestionResult> questionResults;
}

class QuestionResult {
  QuestionResult({
    required this.questionIndex,
    required this.questionText,
    required this.isCorrect,
    required this.answerTexts,
    required this.answerMediaUrls,
    required this.timeTakenMs,
  });

  final int questionIndex;
  final String questionText;
  final bool isCorrect;
  final List<String> answerTexts;
  final List<String> answerMediaUrls;
  final int timeTakenMs;
}
