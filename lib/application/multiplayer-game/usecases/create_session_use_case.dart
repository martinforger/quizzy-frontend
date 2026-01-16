import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';
import '../../../../domain/multiplayer-game/entities/session_entity.dart';

/// Caso de uso para crear una nueva sesión multijugador.
///
/// H4.1 - El anfitrión crea una sala de juego (Lobby) a partir de un Kahoot.
class CreateMultiplayerSessionUseCase {
  final MultiplayerGameRepository _repository;

  CreateMultiplayerSessionUseCase(this._repository);

  /// Crea una nueva sesión multijugador.
  ///
  /// Retorna [SessionEntity] con el PIN, QR token, y datos del quiz.
  Future<SessionEntity> call(String kahootId) async {
    return await _repository.createSession(kahootId);
  }
}
