import '../../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Caso de uso para obtener el PIN de sesión a partir de un token QR.
///
/// H4.3 - Permite a un cliente obtener el sessionPin al escanear un código QR.
class GetSessionPinByQrTokenUseCase {
  final MultiplayerGameRepository _repository;

  GetSessionPinByQrTokenUseCase(this._repository);

  /// Obtiene el PIN de la sesión a partir del token QR.
  Future<String> call(String qrToken) async {
    return await _repository.getSessionPinByQrToken(qrToken);
  }
}
