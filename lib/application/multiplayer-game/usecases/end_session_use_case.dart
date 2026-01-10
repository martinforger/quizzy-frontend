import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para que el host cierre la sesión.
class EndSessionUseCase {
  final MultiplayerGameRepository _repository;

  EndSessionUseCase(this._repository);

  /// Emite el evento host_end_session para cerrar la partida.
  ///
  /// Este evento se debe llamar después de host_game_end para
  /// cerrar formalmente la sesión y desconectar a todos los jugadores.
  void call() {
    _repository.emitHostEndSession();
  }
}
