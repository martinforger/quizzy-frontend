import '../../../domain/solo-game/entities/slide_entity.dart';
import '../../../domain/solo-game/entities/summary_entity.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

/// Estado cuando el usuario está viendo una pregunta y el contador corre
class GameInProgress extends GameState {
  final String attemptId;
  final SlideEntity currentSlide;
  final int currentScore;
  final int currentQuestionIndex;

  GameInProgress({
    required this.attemptId,
    required this.currentSlide,
    required this.currentScore,
    this.currentQuestionIndex = 1,
  });
}

/// Estado inmediatamente después de responder (Feedback: Correcto/Incorrecto)
class GameAnswerFeedback extends GameState {
  final bool wasCorrect;
  final int pointsEarned;
  final int totalScore;
  final SlideEntity? nextSlide; // Puede ser null si el juego terminó

  GameAnswerFeedback({
    required this.wasCorrect,
    required this.pointsEarned,
    required this.totalScore,
    this.nextSlide,
  });
}

/// Estado final con el resumen
class GameFinished extends GameState {
  final SummaryEntity summary;

  GameFinished(this.summary);
}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}
