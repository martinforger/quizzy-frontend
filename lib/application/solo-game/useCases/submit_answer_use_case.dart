import '../../../domain/solo-game/entities/attempt_entity.dart';
import '../../../domain/solo-game/repositories/game_repository.dart';

/// Caso de Uso: H5.3 Enviar respuesta
class SubmitAnswerUseCase {
  final GameRepository _repository;

  SubmitAnswerUseCase(this._repository);

  Future<AttemptEntity> call({
    required String attemptId,
    required String slideId,
    required List<int> answerIndices,
    required int timeElapsed,
  }) async {
    // Validaciones de negocio antes de llamar al repo
    if (timeElapsed < 0) {
      throw Exception("El tiempo no puede ser negativo");
    }

    return await _repository.submitAnswer(
      attemptId: attemptId,
      slideId: slideId,
      answerIndices: answerIndices,
      timeElapsed: timeElapsed,
    );
  }
}
