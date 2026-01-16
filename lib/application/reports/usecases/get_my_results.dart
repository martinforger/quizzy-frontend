import 'package:quizzy/domain/reports/entities/kahoot_result_summary.dart';
import 'package:quizzy/domain/reports/entities/reports_page.dart';
import 'package:quizzy/domain/reports/repositories/reports_repository.dart';

class GetMyResultsUseCase {
  GetMyResultsUseCase(this._repository);

  final ReportsRepository _repository;

  Future<ReportsPage<KahootResultSummary>> call({int page = 1, int limit = 20}) {
    return _repository.getMyResults(page: page, limit: limit);
  }
}
