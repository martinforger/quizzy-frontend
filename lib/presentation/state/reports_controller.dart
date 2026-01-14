import 'package:quizzy/application/reports/usecases/get_multiplayer_result.dart';
import 'package:quizzy/application/reports/usecases/get_my_results.dart';
import 'package:quizzy/application/reports/usecases/get_session_report.dart';
import 'package:quizzy/application/reports/usecases/get_singleplayer_result.dart';
import 'package:quizzy/domain/reports/entities/kahoot_result_summary.dart';
import 'package:quizzy/domain/reports/entities/personal_result.dart';
import 'package:quizzy/domain/reports/entities/reports_page.dart';
import 'package:quizzy/domain/reports/entities/session_report.dart';

class ReportsController {
  ReportsController({
    required this.getSessionReportUseCase,
    required this.getMultiplayerResultUseCase,
    required this.getSingleplayerResultUseCase,
    required this.getMyResultsUseCase,
  });

  final GetSessionReportUseCase getSessionReportUseCase;
  final GetMultiplayerResultUseCase getMultiplayerResultUseCase;
  final GetSingleplayerResultUseCase getSingleplayerResultUseCase;
  final GetMyResultsUseCase getMyResultsUseCase;

  Future<ReportsPage<KahootResultSummary>> getMyResults({
    int page = 1,
    int limit = 20,
  }) {
    return getMyResultsUseCase(page: page, limit: limit);
  }

  Future<PersonalResult> getPersonalResult({
    required String gameType,
    required String gameId,
  }) {
    if (gameType.toLowerCase().contains('multi')) {
      return getMultiplayerResultUseCase(gameId);
    }
    return getSingleplayerResultUseCase(gameId);
  }

  Future<SessionReport> getSessionReport(String sessionId) {
    return getSessionReportUseCase(sessionId);
  }
}
