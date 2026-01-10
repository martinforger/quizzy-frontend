import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para que el host inicie el juego.
class StartMultiplayerGameUseCase {
  final MultiplayerGameRepository _repository;

  StartMultiplayerGameUseCase(this._repository);

  /// Emite el evento host_start_game para iniciar la partida.
  void call() {
    _repository.emitHostStartGame();
  }
}
