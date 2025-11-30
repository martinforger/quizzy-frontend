import '../../../domain/solo-game/entities/attempt_entity.dart';
import '../../../domain/solo-game/repositories/game_repository.dart';

/// Caso de Uso: H5.2 Obtener Estado / Reanudar Partida
/// Permite recuperar una partida pausada o verificar en qué pregunta va el usuario.
class GetAttemptStateUseCase {
  final GameRepository _repository;

  GetAttemptStateUseCase(this._repository);

  Future<AttemptEntity> call(String attemptId) async {
    if (attemptId.isEmpty) {
      throw Exception("El ID del intento no puede estar vacío");
    }
    return await _repository.getAttemptState(attemptId);
  }
}
