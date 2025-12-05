export 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/domain/solo-game/repositories/game_repository.dart';
import 'package:quizzy/domain/solo-game/entities/attempt_entity.dart';

class GetAttemptStateUseCase {
  final GameRepository _repository;

  GetAttemptStateUseCase(this._repository);

  Future<AttemptEntity> call(String attemptId) async {
    return _repository.getAttemptState(attemptId);
  }
}
