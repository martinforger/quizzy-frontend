import 'slide_entity.dart';

class AttemptEntity {
  final String attemptId;
  final String state;
  final int currentScore;

  final SlideEntity? firstSlide;

  final SlideEntity? nextSlide;

  final bool? wasCorrect;

  final int? pointsEarned;

  AttemptEntity({
    required this.attemptId,
    required this.state,
    required this.currentScore,
    this.firstSlide,
    this.nextSlide,
    this.wasCorrect,
    this.pointsEarned,
  });
}
