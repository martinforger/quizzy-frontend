import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para que un jugador se una a una sesión con nickname.
class JoinAsPlayerUseCase {
  final MultiplayerGameRepository _repository;

  JoinAsPlayerUseCase(this._repository);

  /// Emite el evento player_join con el nickname.
  ///
  /// [nickname] - Nombre del jugador (6-20 caracteres)
  void call(String nickname) {
    _repository.emitPlayerJoin(nickname);
  }
}
