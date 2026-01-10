import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para conectarse a una sesión multijugador via WebSocket.
class ConnectToSessionUseCase {
  final MultiplayerGameRepository _repository;

  ConnectToSessionUseCase(this._repository);

  /// Conecta al servidor WebSocket con los parámetros de la sesión.
  ///
  /// [pin] - PIN de la sesión (6-10 dígitos)
  /// [role] - Rol del usuario (HOST o PLAYER)
  /// [jwt] - Token JWT de autenticación
  Future<void> call({
    required String pin,
    required MultiplayerRole role,
    required String jwt,
  }) async {
    await _repository.connect(pin: pin, role: role, jwt: jwt);
  }
}
