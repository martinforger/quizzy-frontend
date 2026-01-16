import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para que un jugador envíe su respuesta.
class SubmitMultiplayerAnswerUseCase {
  final MultiplayerGameRepository _repository;

  SubmitMultiplayerAnswerUseCase(this._repository);

  /// Emite el evento player_submit_answer con la respuesta.
  ///
  /// [questionId] - ID de la slide/pregunta actual
  /// [answerIds] - Lista de IDs de respuestas seleccionadas
  /// [timeElapsedMs] - Tiempo transcurrido en milisegundos
  void call({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    _repository.emitPlayerSubmitAnswer(
      questionId: questionId,
      answerIds: answerIds,
      timeElapsedMs: timeElapsedMs,
    );
  }
}
