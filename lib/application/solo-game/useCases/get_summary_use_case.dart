import '../../../domain/solo-game/entities/summary_entity.dart';
import '../../../domain/solo-game/repositories/game_repository.dart';

/// Caso de Uso: H5.4 Obtener Resumen Final
/// Se llama cuando el juego termina (estado COMPLETED) para mostrar puntajes finales.
class GetSummaryUseCase {
  final GameRepository _repository;

  GetSummaryUseCase(this._repository);

  Future<SummaryEntity> call(String attemptId) async {
    if (attemptId.isEmpty) {
      throw Exception("El ID del intento es requerido para obtener el resumen");
    }
    return await _repository.getSummary(attemptId);
  }
}
