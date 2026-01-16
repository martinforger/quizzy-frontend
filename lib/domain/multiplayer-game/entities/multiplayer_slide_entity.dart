import '../../solo-game/entities/slide_entity.dart';

/// Estado de una pregunta en el juego multijugador.
class MultiplayerQuestionEntity {
  final String state;
  final SlideEntity currentSlideData;
  final int position;
  final int totalQuestions;
  final int? timeRemainingMs;
  final bool? hasAnswered;

  MultiplayerQuestionEntity({
    required this.state,
    required this.currentSlideData,
    required this.position,
    this.totalQuestions = 0,
    this.timeRemainingMs,
    this.hasAnswered,
  });
}

/// Confirmación de respuesta enviada.
class AnswerConfirmationEntity {
  final bool received;
  final String questionId;

  AnswerConfirmationEntity({required this.received, required this.questionId});
}
