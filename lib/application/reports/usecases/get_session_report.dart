import 'package:quizzy/domain/reports/entities/session_report.dart';
import 'package:quizzy/domain/reports/repositories/reports_repository.dart';

class GetSessionReportUseCase {
  GetSessionReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<SessionReport> call(String sessionId) {
    return _repository.getSessionReport(sessionId);
  }
}
