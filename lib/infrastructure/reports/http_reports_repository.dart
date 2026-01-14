import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/domain/reports/entities/kahoot_result_summary.dart';
import 'package:quizzy/domain/reports/entities/personal_result.dart';
import 'package:quizzy/domain/reports/entities/reports_page.dart';
import 'package:quizzy/domain/reports/entities/session_report.dart';
import 'package:quizzy/domain/reports/repositories/reports_repository.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

class HttpReportsRepository implements ReportsRepository {
  HttpReportsRepository({required this.client});

  final http.Client client;

  @override
  Future<SessionReport> getSessionReport(String sessionId) async {
    final uri = _resolve('reports/sessions/$sessionId');
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al obtener reporte de sesión');
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return _mapSessionReport(data);
  }

  @override
  Future<PersonalResult> getMultiplayerResult(String sessionId) async {
    final uri = _resolve('reports/multiplayer/$sessionId');
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al obtener resultado multiplayer');
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return _mapPersonalResult(data);
  }

  @override
  Future<PersonalResult> getSingleplayerResult(String attemptId) async {
    final uri = _resolve('reports/singleplayer/$attemptId');
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al obtener resultado singleplayer');
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return _mapPersonalResult(data);
  }

  @override
  Future<ReportsPage<KahootResultSummary>> getMyResults({int page = 1, int limit = 20}) async {
    final uri = _resolve(
      'reports/kahoots/my-results',
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    _ensureSuccess(response, 'Error al obtener historial de resultados');
    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? [])
        .map((e) => _mapSummary(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ReportsPage(
      results: results,
      totalItems: (meta['totalItems'] as num?)?.toInt() ?? results.length,
      currentPage: (meta['currentPage'] as num?)?.toInt() ?? page,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? limit,
    );
  }

  ReportsPage<KahootResultSummary> _mapResultsPage(Map<String, dynamic> data) {
    final results = (data['results'] as List<dynamic>? ?? [])
        .map((e) => _mapSummary(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ReportsPage(
      results: results,
      totalItems: (meta['totalItems'] as num?)?.toInt() ?? results.length,
      currentPage: (meta['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? results.length,
    );
  }

  KahootResultSummary _mapSummary(Map<String, dynamic> json) {
    return KahootResultSummary(
      kahootId: json['kahootId'] as String? ?? '',
      gameId: (json['gameId'] as String?) ?? (json['attemptId'] as String?) ?? '',
      gameType: (json['gameType'] as String?) ?? 'Singleplayer',
      title: json['title'] as String? ?? '',
      completionDate: DateTime.tryParse(json['completionDate'] as String? ?? '') ?? DateTime.now(),
      finalScore: (json['finalScore'] as num?)?.toInt() ?? 0,
      rankingPosition: (json['rankingPosition'] as num?)?.toInt(),
    );
  }

  SessionReport _mapSessionReport(Map<String, dynamic> json) {
    return SessionReport(
      reportId: json['reportId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      executionDate: DateTime.tryParse(json['executionDate'] as String? ?? '') ?? DateTime.now(),
      playerRanking: (json['playerRanking'] as List<dynamic>? ?? [])
          .map((e) => _mapRanking(e as Map<String, dynamic>))
          .toList(),
      questionAnalysis: (json['questionAnalysis'] as List<dynamic>? ?? [])
          .map((e) => _mapAnalysis(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PlayerRanking _mapRanking(Map<String, dynamic> json) {
    return PlayerRanking(
      position: (json['position'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
    );
  }

  QuestionAnalysis _mapAnalysis(Map<String, dynamic> json) {
    return QuestionAnalysis(
      questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
      questionText: json['questionText'] as String? ?? '',
      correctPercentage: (json['correctPercentage'] as num?)?.toDouble() ?? 0,
    );
  }

  PersonalResult _mapPersonalResult(Map<String, dynamic> json) {
    return PersonalResult(
      kahootId: json['kahootId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      finalScore: (json['finalScore'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      averageTimeMs: (json['averageTimeMs'] as num?)?.toInt() ?? 0,
      rankingPosition: (json['rankingPosition'] as num?)?.toInt(),
      questionResults: (json['questionResults'] as List<dynamic>? ?? [])
          .map((e) => _mapQuestionResult(e as Map<String, dynamic>))
          .toList(),
    );
  }

  QuestionResult _mapQuestionResult(Map<String, dynamic> json) {
    final answerTexts = (json['answerText'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final answerMediaUrls = (json['answerMediaID'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return QuestionResult(
      questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
      questionText: json['questionText'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      answerTexts: answerTexts,
      answerMediaUrls: answerMediaUrls,
      timeTakenMs: (json['timeTakenMs'] as num?)?.toInt() ?? 0,
    );
  }

  Uri _resolve(String path, {Map<String, String>? queryParameters}) {
    final base = BackendSettings.baseUrl;
    final separator = base.endsWith('/') ? '' : '/';
    return Uri.parse('$base$separator$path').replace(queryParameters: queryParameters);
  }

  void _ensureSuccess(http.Response response, String message, {List<int> expected = const [200]}) {
    if (!expected.contains(response.statusCode)) {
      throw Exception('$message: ${response.statusCode} ${response.body}');
    }
  }
}
