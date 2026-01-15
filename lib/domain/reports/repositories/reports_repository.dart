import 'package:quizzy/domain/reports/entities/kahoot_result_summary.dart';
import 'package:quizzy/domain/reports/entities/personal_result.dart';
import 'package:quizzy/domain/reports/entities/reports_page.dart';
import 'package:quizzy/domain/reports/entities/session_report.dart';

abstract class ReportsRepository {
  Future<SessionReport> getSessionReport(String sessionId);

  Future<PersonalResult> getMultiplayerResult(String sessionId);

  Future<PersonalResult> getSingleplayerResult(String attemptId);

  Future<ReportsPage<KahootResultSummary>> getMyResults({
    int page = 1,
    int limit = 20,
  });
}
