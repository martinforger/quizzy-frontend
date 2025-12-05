import '../../../domain/solo-game/entities/attempt_entity.dart';
import '../../../domain/solo-game/repositories/game_repository.dart';

/// Caso de Uso: H5.1 Iniciar un nuevo Kahoot
/// Permite iniciar un nuevo intento de juego.
class StartAttemptUseCase {
  final GameRepository _repository;

  StartAttemptUseCase(this._repository);

  Future<AttemptEntity> call(String kahootId) async {
    if (kahootId.isEmpty) {
      throw Exception("El ID del Kahoot no puede estar vacío");
    }
    return await _repository.startNewAttempt(kahootId);
  }
}
