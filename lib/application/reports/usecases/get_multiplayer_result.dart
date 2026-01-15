import 'package:quizzy/domain/reports/entities/personal_result.dart';
import 'package:quizzy/domain/reports/repositories/reports_repository.dart';

class GetMultiplayerResultUseCase {
  GetMultiplayerResultUseCase(this._repository);

  final ReportsRepository _repository;

  Future<PersonalResult> call(String sessionId) {
    return _repository.getMultiplayerResult(sessionId);
  }
}
