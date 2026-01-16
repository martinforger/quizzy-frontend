import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para que el host avance a la siguiente fase.
class NextPhaseUseCase {
  final MultiplayerGameRepository _repository;

  NextPhaseUseCase(this._repository);

  /// Emite el evento host_next_phase para avanzar en el juego.
  ///
  /// Transiciones posibles:
  /// - QUESTION → RESULTS (muestra resultados)
  /// - RESULTS → QUESTION (siguiente pregunta)
  /// - RESULTS → END (última pregunta contestada)
  void call() {
    _repository.emitHostNextPhase();
  }
}
