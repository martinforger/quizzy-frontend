import '../../../domain/solo-game/repositories/game_repository.dart';
import '../../../domain/solo-game/entities/attempt_entity.dart';
import '../../../domain/solo-game/entities/summary_entity.dart';
import '../data_sources/game_remote_data_source.dart';
import '../models/attempt_model.dart';
import '../models/summary_model.dart';

import '../data_sources/local_game_storage.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource _remoteDataSource;
  final LocalGameStorage _localGameStorage;

  GameRepositoryImpl(this._remoteDataSource, this._localGameStorage);

  @override
  Future<AttemptEntity> startNewAttempt(String kahootId) async {
    try {
      final response = await _remoteDataSource.startNewAttempt(kahootId);
      return AttemptModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (Start): $e");
    }
  }

  @override
  Future<AttemptEntity> getAttemptState(String attemptId) async {
    try {
      final response = await _remoteDataSource.getAttemptState(attemptId);
      return AttemptModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (GetState): $e");
    }
  }

  @override
  Future<AttemptEntity> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndices,
    required int timeElapsed,
  }) async {
    try {
      final body = {
        "slideId": slideId,
        "answerIndexes": answerIndices,
        "timeElapsedSeconds": timeElapsed,
      };

      final response = await _remoteDataSource.submitAnswer(attemptId, body);
      return AttemptModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (Submit): $e");
    }
  }

  @override
  Future<SummaryEntity> getSummary(String attemptId) async {
    try {
      final response = await _remoteDataSource.getAttemptSummary(attemptId);
      return SummaryModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (Summary): $e");
    }
  }

  @override
  Future<void> saveLocalGameSession({
    required String quizId,
    required String attemptId,
    required int currentQuestionIndex,
    required int totalQuestions,
  }) async {
    return _localGameStorage.saveSession(
      quizId: quizId,
      attemptId: attemptId,
      currentQuestionIndex: currentQuestionIndex,
      totalQuestions: totalQuestions,
    );
  }

  @override
  Future<Map<String, dynamic>?> getLocalGameSession(String quizId) async {
    return _localGameStorage.getSession(quizId);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllLocalGameSessions() async {
    return _localGameStorage.getAllSessions();
  }

  @override
  Future<void> clearLocalGameSession(String quizId) async {
    return _localGameStorage.clearSession(quizId);
  }
}
