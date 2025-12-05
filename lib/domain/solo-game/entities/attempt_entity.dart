import 'slide_entity.dart';

class AttemptEntity {
  final String attemptId;
  final String state;
  final int currentScore;

  final SlideEntity? firstSlide;

  final SlideEntity? nextSlide;

  final bool? wasCorrect;

  final int? pointsEarned;

  final int currentQuestionIndex;
  final int totalQuestions;

  AttemptEntity({
    required this.attemptId,
    required this.state,
    required this.currentScore,
    this.currentQuestionIndex = 0,
    this.totalQuestions = 0,
    this.firstSlide,
    this.nextSlide,
    this.wasCorrect,
    this.pointsEarned,
  });
}
