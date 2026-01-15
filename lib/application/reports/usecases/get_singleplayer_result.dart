import 'package:quizzy/domain/reports/entities/personal_result.dart';
import 'package:quizzy/domain/reports/repositories/reports_repository.dart';

class GetSingleplayerResultUseCase {
  GetSingleplayerResultUseCase(this._repository);

  final ReportsRepository _repository;

  Future<PersonalResult> call(String attemptId) {
    return _repository.getSingleplayerResult(attemptId);
  }
}
